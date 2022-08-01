import logging
from itertools import tee
from typing import Iterable, List, Optional, Sequence, Tuple, TypeVar

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

from .pandas_transformer_abc import PandasDFAbstractTransformer

try:
    import torch
    import torch.nn as nn
    from torch.utils.data import Dataset, DataLoader
except ImportError:
    torch = None
    nn = None
    Dataset = object
    DataLoader = object

LOGGER = logging.getLogger(__name__)


class Autoencoder(PandasDFAbstractTransformer):
    """Autoencoder transformer.

    Parameters:
        shape (List[:class:`int`]): List of dimensions in order from
            input dimension to encoding dimension, e.g. a value of [70,
            64, 32] will result in an autoencoder of shape 70 -> 64 ->
            32 -> 64 -> 70. Must contain at least 2 elements.
        noise_type (Optional[:class:`str`]): One of "gaussian" or "masking".
            Determines the type of noise added to the data before being
            autoencoded. If `None`, no noise is added.
        noise_amount (Optional[:class:`float`]): Only used if
            ``noise_type`` is not `None`. For masking noise, this is the
            probability that each element of the input will be set to 0.
            For gaussian noise, this is the standard deviation of the
            noise that is added to the input.
        relational (pair of :class:`float`): ``(weight, cutpoint)``
            parameters for Relational Autoencoder loss term. First
            element is weight of the loss term (between 0 and 1), and
            second is cutpoint of considered relationships. For more
            information see the white paper `Relational Autoencoder for
            Feature Extraction`_.
        l1 (Optional[:class:`float`]): Weight of L1 regularisation term
            added to the loss function. Used to enforce sparsity
            condition for a Sparse Autoencoder.
        kl (pair of :class:`float`): ``(weight, target_distribution)``
            parameters for KL Divergence loss in a Sparse Autoencoder.
            First element is weight of the loss term, and second is the
            target probability distribution for the activations. A
            sensible value for ``target_distribution`` is a small number
            close to 0, e.g. 0.05. For more information see this paper
            on `Sparse Autoencoders`_.
        epochs (:class:`int`): Maximum number of epochs to train for.
            Defaults to 100.
        patience (:class:`int`): Number of epochs before early stopping
            ends training. If the validation loss does not beat the
            current best validation loss by at least ``tol`` for
            ``patience`` epochs, the training will end early. Only used
            if ``val_set_size`` is not 0. Defaults to 5.
        tol (:class:`float`): Minimum required drop in validation loss
            for early stopping. Only used if ``val_set_size`` is not 0.
            Defaults to 0.0001.
        val_set_size (:class:`float`): Fraction of training data to use
            for validation. If 0, no validation or early stopping takes
            place. Defaults to 0.1.
        lr (:class:`float`): Learning rate of the model. Defaults to
            0.001.
        batch_size (:class:`int`): Size of each training mini batch.
            Defaults to 256.
        random_state (:class:`int`): Seed to use when initialising and
            training model. Defaults to 0.

    .. _`Relational Autoencoder for Feature Extraction`: https://arxiv.org/pdf/1802.03145.pdf
    .. _`Sparse Autoencoders`: https://web.stanford.edu/class/cs294a/sparseAutoencoder.pdf

    """

    DEFAULT_PARAMETERS = dict(
        epochs=100,
        noise_type=None,
        noise_amount=None,
        relational=None,
        l1=None,
        kl=None,
        patience=5,
        tol=0.0001,
        val_set_size=0.1,
        lr=0.001,
        batch_size=256,
        seed=0,
    )

    def __init__(self, config: Optional[dict] = None, **kwargs):
        if torch is None:
            raise RuntimeError("PyTorch is not installed - cannot create Autoencoder")
        super().__init__(config, **kwargs)

        # TODO Accept different activations and losses
        self.base_loss = nn.MSELoss()
        self.activation = nn.Sigmoid()

        self.encoder = None
        self.decoder = None
        self.module = None

        if not isinstance(self.parameters.get("shape"), (tuple, list)):
            raise ValueError("The 'shape' parameter to the Autoencoder is required")

        if self.parameters["noise_type"] and self.parameters["noise_amount"]:
            if self.parameters["noise_type"] == "masking":
                self.noise_func = MaskingNoiser(self.parameters["noise_amount"])
            elif self.parameters["noise_type"] == "guassian":
                self.noise_func = GaussianNoiser(self.parameters["noise_amount"])
            else:
                raise ValueError(
                    f"Unknown noise type {self.parameters['noise_type']!r}"
                )
        else:
            self.noise_func = None

        # Make code device agnostic i.e. use a gpu if one is available
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        """Instantiates and Trains the model on the given data."""
        torch.manual_seed(self.parameters["seed"])
        np.random.seed(self.parameters["seed"])

        if len(dataset) > 1:
            LOGGER.warning(
                "Autoencoder cannot fit on multiple batches yet! Only the first batch "
                "will be used to train the transformer"
            )

        # Fit on only the first batch (batch-fitting is not supported
        # yet)
        self._fit_df(dataset[0])

    def _fit_df(self, df: pd.DataFrame) -> None:
        shape = [df.shape[1], *self.parameters["shape"]]
        encoder = []
        for curr, next_ in pairwise(shape):
            encoder.append(nn.Linear(curr, next_))
            encoder.append(self.activation)
        self.encoder = nn.Sequential(*encoder)

        # Build linear decoder that is exact reverse shape of encoder
        shape.reverse()
        decoder = []
        for curr, next_ in pairwise(shape):
            decoder.append(nn.Linear(curr, next_))
            decoder.append(self.activation)

        # Remove final activation function so outputs aren't put through activation function
        decoder.pop(-1)
        self.decoder = nn.Sequential(*decoder)

        # Join encode and decoder in series
        self.module = nn.Sequential(self.encoder, self.decoder)

        LOGGER.debug("Initialised Autoencoder with shape %s", self.module)

        optimizer = torch.optim.Adam(self.module.parameters(), lr=self.parameters["lr"])

        # Split for an early stopping validation set
        val_size = self.parameters["val_set_size"]
        if val_size != 0:
            df, val_df = train_test_split(df, test_size=val_size)
            val_set = Data(val_df)
        else:
            val_set = None

        # Define train dataloader
        train_set = Data(df)
        dataloader = DataLoader(train_set, batch_size=self.parameters["batch_size"])

        # Start training loop
        self.module.train()
        val_losses = []
        best_val_loss = 1e9
        patience_counter = 0
        for epoch in range(self.parameters["epochs"]):
            losses = []
            for batch in dataloader:
                data = batch.to(self.device)
                processed_data = self._preprocessor(data)
                output = self.module(processed_data)
                optimizer.zero_grad()
                loss = self._loss_func(output, data)

                loss.backward()
                optimizer.step()
                losses.append(loss.item())

            # Early stopping if validation loss does not improve for `patience` batches
            if val_size:
                val_losses.append(self._val(val_set))
                val_loss = val_losses[-1]
                if best_val_loss - val_loss <= self.parameters["tol"]:
                    patience_counter += 1
                    if patience_counter >= self.parameters["patience"]:
                        LOGGER.info("Early stopping with val loss: %s", val_loss)
                        break
                else:
                    best_val_loss = val_loss
                    patience_counter = 0

            LOGGER.info("Average epoch train loss: %s", np.mean(losses))

    def _transform_df(self, df: pd.DataFrame, *, is_fit: bool = False):
        data = Data(df)
        encoded_dataset = self.encoder(data.data)
        encoded_array = encoded_dataset.detach().numpy()
        return self._label_output(
            encoded_array, index=df.index, original_columns=df.columns
        )

    def _preprocessor(self, data):
        if not self.noise_func:
            return data
        return self.noise_func(data)

    def _loss_func(self, outputs, targets):
        """Computes total loss between ``outputs`` and ``targets``

        Combines the base loss function with any additional loss terms
        that have been added

        Args:
            outputs (torch.Tensor): the output of the Autoencoder
            targets (torch.Tensor):  the desired output of the Autoencoder
                (usually equal to the input to the Autoencoder)

        Returns:
            torch.Tensor: the loss between the two tensors
        """
        loss = self.base_loss(outputs, targets)

        if self.parameters["l1"]:
            weight = True  # We only penalise the weights, not the biases, with L1
            for param in self.module.parameters():
                if weight:
                    loss += self.parameters["l1"] * nn.L1Loss()(
                        param, torch.zeros(param.shape, device=self.device)
                    )
                weight = not weight  # Every second parameter are biases not weights

        if self.parameters["kl"]:
            beta = float(self.parameters["kl"][0])
            p = float(self.parameters["kl"][1])
            activation = False  # We only care about the activations of each neuron
            x = targets
            x.to(self.device)  # Send ``x`` to GPU if available
            for coder in [self.encoder, self.decoder]:
                for layer in coder:
                    x = layer(x)
                    if activation:
                        # ``p_hat`` stores the average of activation of each neuron over the batch
                        p_hat = x.mean(0)
                        # Calculate the KL Divergence between average activation ``p_hat``
                        # and the target distribution ``p``
                        kl_loss = beta * (
                            p * torch.log(p / p_hat)
                            + (1 - p) * torch.log((1 - p) / (1 - p_hat))
                        )
                        loss += kl_loss.sum()

                    # Every second layer is unactivated neurons
                    activation = not activation

        if self.parameters["relational"]:
            alpha = float(self.parameters["relational"][0])
            thresh = nn.Threshold(float(self.parameters["relational"][1]), 0)
            loss = (1 - alpha) * loss + alpha * self.base_loss(
                thresh(torch.matmul(targets, targets.T)),
                thresh(torch.matmul(outputs, outputs.T)),
            )
        return loss

    def _val(self, val_set):
        """Calculate validation reconstruction error of network

        The reconstruction error is calculated using :attr:`~loss_func`

        Args:
            val_set (Data): The validation set used to calculate the reconstruction error

        Returns:
            float:  The reconstruction loss of the validation set
        """
        self.module.eval()
        val_data = val_set.data.to(self.device)
        return self._loss_func(self.module(val_data), val_data).item()


class Data(Dataset):
    def __init__(self, data):
        """Implementation of Pytorch Dataset class

        Args:
            data (Sequence[Union[DataFrame, ndarray, Tensor]]: The data to be stored,
                shape must be (N, F) where N is number of samples,
                and F is number of features
        """
        device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
        self.data = torch.tensor(np.array(data), dtype=torch.float, device=device)

    def __len__(self):
        return self.data.shape[0]

    def __getitem__(self, idx):
        return self.data[idx]


class Noiser:
    """Class of strategies to add noise to data"""

    def __init__(self, noise):
        self.noise = float(noise)
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    def __call__(self, data):
        return self.noiser(data)

    def noiser(self, data):
        return data


class GaussianNoiser(Noiser):
    def __init__(self, noise):
        """Construct a Noiser that adds gaussian noise to data

        Args:
            noise (float): The standard deviation of the gaussian noise to be added
        """
        super().__init__(noise)

    def noiser(self, data):
        """Adds gaussian noise to data

        Gaussian noise with a standard deviation of :attr:`~noise` is added to
        each element of the ``data`` tensor

        Args:
            data (torch.Tensor): The data to add noise to

        Returns:
            torch.Tensor: The noisy data
        """
        noiser = torch.tensor(
            np.random.normal(0, self.noise, data.shape),
            dtype=torch.float,
            device=self.device,
        )
        return data + noiser


class MaskingNoiser(Noiser):
    def __init__(self, noise):
        """Construct a Noiser that adds masking noise to data

        Args:
            noise: The probability of each element to be set to 0
        """
        super().__init__(noise)

    def noiser(self, data):
        """Add masking noise to data

        Each element of the ``data`` tensor has a ``self.noise`` chance of being set to 0

        Args:
            data (torch.Tensor): The data to add noise to

        Returns:
            torch.Tensor: The masked (noisy) data
        """
        noiser = torch.tensor(
            np.random.choice([0, 1], size=data.shape, p=[self.noise, 1 - self.noise]),
            dtype=torch.float,
            device=self.device,
        )
        return data * noiser


_T = TypeVar("_T")


def pairwise(iterable: Iterable[_T]) -> Iterable[Tuple[_T, _T]]:
    """s -> (s[0], s[1]), (s[1], s[2]), (s[2], s[3]), ...

    Comes from "Itertools Recipes":
    https://docs.python.org/3/library/itertools.html#itertools-recipes
    """
    # Create two copies of the original iterable
    a, b = tee(iterable)
    # Move the 2nd iterable forward by one
    next(b, None)
    # Yield elements of each iterable in pairs
    return zip(a, b)
