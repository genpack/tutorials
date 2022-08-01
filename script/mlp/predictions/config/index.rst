The Predictions Config
======================
The Predictions config can generally be specified in 4 different formats, for 4 different purposes:

1. Training a model, including:

   a. Training a single model
   b. Training an ensemble of models

2. Using a pre-trained model to make inferences
3. Optimising the hyper-parameters of a model
4. Performing feature selection.

Config Reference
----------------

.. toctree::
    :maxdepth: 1
    :hidden:

    Models <model>
    HPO <hpo>
    Feature Selection <feature_selection>

Root-Level Keys
+++++++++++++++

Every config has a few common root-level keys:

- ``dataset`` (Required in the pipeline, uuid): The run ID for the sampled dataset to use.
- ``mode`` (Required in the pipeline, string): Either *infer* (for inference jobs) or *train* (for all other purposes).
- ``max_memory_GB`` (Optional, number): The maximum size (in GB) of each batch of data loaded into memory. By default, batching is disabled, so if the dataset is large enough, omitting this field (or setting it too high) can result in the model running out of memory.
- ``model`` (Required, :ref:`model object <model_obj>`): A description of the model for one of the four purposes outlined above.

The following root-level key is also available to all types of prediction jobs apart from inferences:

- ``optimise``: (Optional, boolean or number or string): How to optimise the decision boundary of the classifier. Defaults to ``false``. Other options include:

  - ``true``: Optimise the decision boundary to achieve the best possible F1 score on the *optimise* dataset.
  - A number between 0 and 1: Set the decision boundary such that the specified proportion of the samples in the *optimise* dataset will be classified as positive.
  - ``"churn"``: Same as specifying a number, where that number is the proportion of positive cases in the *optimise* dataset (i.e. the same as setting it to the "churn rate" when predicting for churn).

The following root-level key is also available for any jobs that use a Distributor (i.e. Ensembles, HPO, and Feature Selection):

- ``distributor``: (Optional, dict): Configuration for model timeouts and distributor budgets. The following sub-keys are supported:

  - ``model_timeout`` (Optional, str): A timespec string (e.g. ``'4h30m'``) specifying the timeout of each model distributed by the Distributor
  - ``total_compute_budget`` (Optional, str): A timespec string (e.g. ``'500h'``) specifying the maximum allowed total runtime of all models submitted by the Distributor


The following additional key is required for HPO jobs:

- ``hpo`` (Required, :ref:`hpo object <hpo_obj>`): HPO configuration.

The following additional key is required for feature selection jobs:

- ``feature_selection`` (Required, :ref:`feature_selection object <feature_selection_obj>`): Feature selection configuration.


Config Sub-Sections
+++++++++++++++++++

.. list-table::
   :header-rows: 1

   * - Section
     - Description
   * - :ref:`model object <model_obj>`
     - Defines a model. Required for all prediction jobs.
   * - :ref:`hpo object <hpo_obj>`
     - Defines an HPO experiment.
   * - :ref:`feature_selection object <feature_selection_obj>`
     - Defines a feature selection experiment.
