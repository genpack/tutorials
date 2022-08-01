"""
Implementation of xgboost that inherits from our classifier ABC
"""

import json
import logging
from typing import Optional

try:
    import torch
    import torch.nn as nn  # Do not swap the order of these imports. These must come first.
    from torch.utils.data import DataLoader, Dataset
except ImportError:
    torch = None
    nn = None
    DataLoader = None
    Dataset = object

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

from .pandas_classifier_abc import AbstractPandasClassifier

LOGGER = logging.getLogger(__name__)


# Inherit a Pytorch NN Classifier from an abstract class

MODEL_DTYPE = nn and nn.Sequential


class PyTorchNeuralNetClassifier(AbstractPandasClassifier):
    """
    Feed Forward NN classifier implemented in Pytorch

    Key parameters and documentation:
    https://pytorch.org/docs/stable/index.html

    The network sequentially applies a linear layer, the activation function,
    then batch norm and dropout if specified. The output layer is neither activated,
    nor subjected to dropout and batch norm.

    Parameters:
        shape (array-like): Specifies the shape of the network. Either a
            list of ints representing each dimension size, or a list of
            (initial_dim: int, n_layers: int, scale_factor: float). The
            network will always end in an output layer of size ``n_classes``,
            which is counted in n_layers. e.g. shape (1024, 256, 64, 16)
            will give network of shape 1024 -> 256 -> 54 -> 16 -> n_classes
            shape (500, 4, 0.2) will give network of shape 500 -> 100 -> 20
            -> 4 -> n_classes.
        activation (str): The activation function used between the layers of
            the network. Either 'relu', 'sigmoid', or 'tanh'.
        loss_func (callable): The loss function used by the model. Must be
            compatible with pytorch tensors.
        patience (int): Number of epochs before early stopping ends
            training. If the validation loss does not beat the current best
            validation loss by at least ``tol`` for ``patience`` epochs, the
            training will end early.
        tol (float): Minimum required drop in validation loss for early
            stopping. Only used if ``early_stopping_test_size`` is set.
        batch_size (int): Size of mini batches used in training/fitting
        lr (float): Learning rate used by optimiser.
        weight_decay (float): Amount of L2 regularisation to apply to the
            weights. Handled by pytorch optimiser.
        prev_output (int): If specified, creates an initial bridging layer
            of shape prev_output -> initial_dim. Useful if using this
            network as the classifier in a PretrainedFF.
        n_classes (int): Determines the size of the output layer. Should be
            at least 2 even for binary classification.
        dropout (float): Value between 0 and 1 that defines the proportion
            of nodes to set to zero during training. For more details see
            http://jmlr.org/papers/volume15/srivastava14a/srivastava14a.pdf.
            Dropout is applied to every layer except the final.
        batch_norm (bool): If True, batch normalisation is applied to all
            layers except the final. For more details see
            https://arxiv.org/abs/1502.03167.
        bn_eps (float): Parameter for Pytorch implementation of batch norm.
            From their documentation: "A value added to the denominator for
            numerical stability". For more details on the Pytorch
            parameters, see https://pytorch.org/docs/stable/nn.html?highlight=batchnorm#torch.nn.BatchNorm1d.
        bn_momentum (float): Parameter for Pytorch implementation of batch
            norm. From their documentation: "The value used for the
            running_mean and running_var computation. Can be set to None
            for cumulative moving average (i.e. simple average)."
        bn_affine (bool): Parameter for Pytorch implementation of batch
            norm. From their documentation: "A boolean value that when set
            to True, this module has learnable affine parameters."
        bn_stats (bool): Parameter for Pytorch implementation of batch norm.
            From their documentation: "a boolean value that when set to
            True, this module tracks the running mean and variance, and when
            set to False, this module does not track such statistics and
            always uses batch statistics in both training and eval modes."

    """

    WARM_START = True
    DEFAULT_PARAMETERS = dict(
        early_stopping_test_size=0.3,
        shape=(500, 200),
        patience=20,
        tol=1e-4,
        batch_size=256,
        num_epochs=20,
        lr=1e-3,
        weight_decay=0,
        n_classes=2,
        dropout=0,
        batch_norm=False,
        bn_eps=1e-5,
        bn_momentum=0.1,
        bn_affine=True,
        bn_stats=True,
        random_state=0,
        loss_func=nn and nn.CrossEntropyLoss(),
        activation="relu",
    )
    model: MODEL_DTYPE

    def __init__(self, config: Optional[dict] = None):
        super().__init__(config)
        self.model = None
        self.optimizer = None
        # Make code device agnostic i.e. use a gpu if one is available
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

        # Allow for alternate activations, default to ReLU if invalid argument
        activations = {"relu": nn.ReLU(), "sigmoid": nn.Sigmoid(), "tanh": nn.Tanh()}
        self.parameters["activation"] = activations.get(
            self.parameters["activation"], nn.ReLU()
        )

        # Early Stopping flags and variables
        # Flag that prevents further training if True
        self.early_stopped = False
        # Counter for early stopping
        self.patience_counter = 0
        # Initial best loss set to very large number
        self.best_val_loss = 1e12
        self.epochs = 0
        self.num_epochs = self.parameters["num_epochs"]

        self.input_dim = None

    def reset(self):
        """
        Initialize Pytorch Feed Forward Neural Network.
        All settings are fed in from the config file to self.params
        As the number of features is required to build the model,
        initialisation cannot occur until fit. See ``_build_model()``
        for actual initialisation code.
        """
        pass

    def _fit(self, X, y):
        """
        Fit model - assumes warm start
        """

        self.set_training_seeds()
        torch.manual_seed(self.parameters["random_state"])

        # If model has not yet been built, construct the model with the correct input dimension
        if self.model is None:
            self._build_model(X.shape[1])

        # Do not continue if model has early stopped
        if self.early_stopped:
            LOGGER.info("Early stopped after {} epochs".format(self.epochs))
            return

        # Split for early stopping
        LOGGER.debug("X shape {}, y shape {} going into split".format(X.shape, y.shape))
        if self.parameters["early_stopping_test_size"] == 0:
            X_train = X
            Y_train = y
        else:
            X_train, X_test, Y_train, Y_test = train_test_split(
                X,
                y,
                stratify=y,
                test_size=self.parameters["early_stopping_test_size"],
                random_state=self.parameters["random_state"],
            )
            test_dataset = Data(X_test, Y_test)
            LOGGER.debug(
                "X_train shape {}, X_test shape {} coming out of  split, ytrain {} , ytest {}".format(
                    X_train.shape, X_test.shape, Y_train.shape, Y_test.shape
                )
            )

        self.model.train()
        dataset = Data(X_train, Y_train)

        dataloader = DataLoader(
            dataset, batch_size=self.parameters["batch_size"], shuffle=True
        )

        for batch in dataloader:
            data, labels = batch
            data = data.to(self.device)
            labels = labels.to(self.device)
            output = self.model(data)
            self.optimizer.zero_grad()
            loss = self.parameters["loss_func"](output, labels)

            loss.backward()
            self.optimizer.step()

        # Early stopping if validation loss does not improve for `patience` batches
        if self.parameters["early_stopping_test_size"] != 0:
            val_loss = self._val(test_dataset)
            if self.best_val_loss - val_loss <= self.parameters["tol"]:
                self.patience_counter += 1
                if self.patience_counter >= self.parameters["patience"]:
                    self.early_stopped = True
            else:
                self.best_val_loss = val_loss
                self.patience_counter = 0

        self.epochs += 1

    def _build_model(self, input_dim):
        LOGGER.debug("Initializing model with params {}".format(self.parameters))

        self.set_training_seeds()
        torch.manual_seed(self.parameters["random_state"])

        # Build Network Structure
        shape = self.parameters["shape"]
        classifier = []

        # First dimension is bridging dimension from input layer to first hidden layer
        self.input_dim = input_dim
        classifier += self._build_layer(self.input_dim, shape[0], self.parameters)

        # if `shape` is of form (initial_dim, n_layers, scale_factor)
        if len(shape) == 3 and isinstance(shape[2], float):
            initial_dim, n_layers, scale = shape
            curr = initial_dim

            for _ in range(n_layers - 1):
                next = int(scale * curr)
                classifier += self._build_layer(curr, next, self.parameters)
                curr = next

            classifier.append(nn.Linear(curr, self.num_classes))

        # else `shape` specifies all dimensions
        else:
            for curr, next in zip(shape, shape[1:]):
                classifier += self._build_layer(curr, next, self.parameters)
            classifier.append(nn.Linear(shape[-1], self.num_classes))

        self.model = nn.Sequential(*classifier)
        self.model.predict_proba = self._predict_proba

        # TODO add support for different optimisers
        self.optimizer = torch.optim.Adam(
            self.model.parameters(),
            lr=self.parameters["lr"],
            weight_decay=self.parameters["weight_decay"],
        )

        LOGGER.info("model initialised: {}".format(self.model))

    def _val(self, val_set):
        """Calculate validation reconstruction error of network

        The reconstruction error is calculated using `self.loss_func`

        Parameters
        ----------
        val_set : Data
            The validation set used to calculate the reconstruction error

        Returns
        -------
        float
            The reconstruction loss of the validation set
        """
        self.model.eval()
        val_data = val_set.data.to(self.device)
        val_labels = val_set.labels.to(self.device)
        return self.parameters["loss_func"](self.model(val_data), val_labels).item()

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        """Predict using the Feed Forward classifier

        Parameters
        ----------
        X : array-like
            The input data. Must be of shape (N, F) where N is the number of samples, and
            F is the number of features
        Returns
        -------
        np.array
            The predicted classes. Array will be of shape (N)
        """
        with torch.no_grad():
            X_tensor = torch.tensor(X.to_numpy(), dtype=torch.float, device=self.device)
            return pd.DataFrame(
                torch.softmax(self.model(X_tensor), 1).numpy(),
                index=X.index,
            )

    @staticmethod
    def _build_layer(input_size, output_size, params):
        """Construct a list of nn.Modules that constitute one layer of the network

        Parameters
        ----------
        input_size : int
            Size of each input sample
        output_size : int
            size of each output sample
        params : dict
            Dictionary of various parameters required to initialise a layer.
            See __init__ function for more information

        Returns
        -------
        layer : list of nn.Module
            A list of all the modules as specified by `params`
        """
        layer = [nn.Linear(input_size, output_size), params["activation"]]
        if params["batch_norm"]:
            bn = nn.BatchNorm1d(
                output_size,
                params["bn_eps"],
                params["bn_momentum"],
                params["bn_affine"],
                params["bn_stats"],
            )
            layer.append(bn)
        if params["dropout"]:
            layer.append(nn.Dropout(p=params["dropout"]))
        return layer

    def _save_json(self, path):
        """Save the model parameters in JSON format

        Converts the tensors inside the model state dictionary into lists of floats, then serialises to JSON

        Parameters
        ----------
        path : str
            Destination file path (should end with .json)
        """
        state_dict = self.model.state_dict()

        for key, value in state_dict.items():
            state_dict[key] = value.tolist()

        with open(path, "w") as f:
            json.dump(state_dict, f)

    def _load_json(self, wrapper, path):
        """Load model parameters from JSON and predict results

        Deserialises the JSON file into state dictionary of lists of floats, then converts to tensors on correct device

        Parameters
        ----------
        wrapper: PyTorchNeuralNetClassifier
            A wrapper with its `model` attribute of the same shape as the model stored at `path`
        path : string
            Path to file to load parameters from (JSON)
        """

        with open(path, "r") as f:
            state_dict = json.load(f)

        for key, value in state_dict.items():
            state_dict[key] = torch.tensor(value, device=self.device)

        wrapper._build_model(wrapper.input_dim)
        wrapper.model.load_state_dict(state_dict)


class Data(Dataset):
    def __init__(self, data, labels):
        """Implementation of Pytorch Dataset class

        Parameters
        ----------
        data : iterable (DataFrame, ndarray, Tensor)
            The data to be stored, shape must be (N, F)
            where N is number of samples, and F is number of features
        labels : iterable (DataFrame, ndarray, Tensor)
            The class label for each sample, shape must be (N)
        """
        device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
        self.data = torch.tensor(np.array(data), dtype=torch.float, device=device)
        self.labels = torch.squeeze(
            torch.tensor(np.array(labels), dtype=torch.long, device=device)
        )

    def __len__(self):
        return self.labels.shape[0]

    def __getitem__(self, idx):
        return self.data[idx], self.labels[idx]
