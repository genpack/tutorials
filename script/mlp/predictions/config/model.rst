Specifying a Model
==================

.. _model_obj:

``model`` Object
++++++++++++++++

The ``model`` section of the config has two forms: one for *infer*, and one for *train*.

For *infer*, the ``model`` object should have these keys:

- ``executorrun`` (Required, uuid): The executor run ID for the model to re-use.
- ``modulerun`` (Required, uuid): The model run ID for the model to re-use.

For all other purposes, the ``model`` object supports these keys:

- ``classifier`` (Required, :ref:`classifier object <model_classifier_obj>`): Specification for the classifier to train.
- ``transformer`` (Optional, :ref:`transformer object <model_transformer_obj>`): Specification for a transformer, which transforms the dataset prior to train and/or infer. When unspecified, the classifier is trained on an unchanged dataset.
- ``features`` (Optional, list of string): Names of features to use (from the input dataset) for training the model.
- ``labels`` (Optional, list of string): Names of columns to load from the dataset which aren't necessarily features. Normally these would be the column(s) which make up the label. Defaults to ``[label]``. Note that this does not necessarily change the ``target`` of the :ref:`classifier <model_classifier_obj>`!.

.. _model_classifier_obj:

``classifier`` Object
^^^^^^^^^^^^^^^^^^^^^
The ``model.classifier`` section supports the following keys:

- ``type`` (Required, string): The type of classifier to use, e.g. :class:`~ell.predictions.classification.XGBClassifier` or :class:`~ell.predictions.ensembling.AveragingEnsembler`. This is the (unqualified) class name of the :class:`~ell.predictions.classification.AbstractClassifier` (or :class:`~ell.predictions.ensembling.AbstractAverager`) implementation.
- ``parameters`` (Optional, dict): Parameters to the classifier.
- ``target`` (Optional, string): The name of the column to use as the label for the classification target. Defaults to ``label``.

For classifiers which are ensemblers (i.e. if ``model.classifier.type`` is set to some implementation of :class:`~ell.predictions.ensembling.AbstractAverager`), then the following key is required:

- ``models`` (Required, list of :ref:`model objects <model_classifier_obj>`): The model(s) to train as part of the ensemble. Each model in the list corresponds with a number in the ``model.classifier.parameters.num_models`` list, which prescribes how many of those models to ensemble.

.. _model_transformer_obj:

``transformer`` Object
^^^^^^^^^^^^^^^^^^^^^^
The ``model.transformer`` object supports the following keys:

- ``type`` (Required, string): The type of transformer to use, e.g. :class:`~ell.predictions.transformation.Dummifier` or :class:`~ell.predictions.transformation.Parallel`. This is the (unqualified) class name of the :class:`~ell.predictions.transformation.AbstractTransformer` implementation.
- ``parameters`` (Optional, dict): Parameters to the transformer.
- ``input``: (Optional, :ref:`input object <model_transformer_input_obj>`): The specification for the input to the transformer. This is essentially for filtering which columns go into the transformer.
- ``output``: (Optional, :ref:`output object <model_transformer_output_obj>`): The specification for the output from the transformer. This is essentially to configure how the output columns are named, and is especially useful with the :class:`~ell.predictions.transformation.ScikitLearnTransformer`.

The following additional key is required by the :class:`~ell.predictions.transformation.Parallel` and :class:`~ell.predictions.transformation.Series` transformers:

- ``steps`` (Required, list of :ref:`transformer objects <model_transformer_obj>`): The steps of the transformer.

The following additional keys are supported by the :class:`~ell.predictions.transformation.ScikitLearnTransformer`:

- ``import_path`` (Required, string): The import path for the transformer class. The transformer class must adhere to the Scikit-Learn transformer interface.
- ``do_xy_split`` (Optional, boolean): If ``true``, the transformer will split out X and y (using ``model.classifier.target``) before fitting the underlying transformer.

The following additional key is required by the :class:`~ell.predictions.transformation.ClassifierAsTransformer`:

- ``classifier_type`` (Required, string): The type of classifier to use.

.. _model_transformer_input_obj:

``input`` Object
****************
This specifies which columns should be fed into a transformer. The behaviour is based on an include/exclude system, where columns can be filtered either by name or type.

The following keys are supported:

- ``include`` (Optional, list or :ref:`column filter object <column_filter_object>`): Either the explicit names of features to include, or a column filter object to filter by some other criteria.
- ``exclude`` (Optional, list or :ref:`column filter object <column_filter_object>`): Same as ``include`` but excludes the specified columns.
- ``exclude_before_include`` (Optional, boolean): By default, the filter is applied by including the the ``include`` columns first, then excluding the ``exclude`` columns afterwards. Set this field to ``true`` to reverse those steps. This is only really useful if the ``include`` and ``exclude`` specifications overlap somehow.

The following key is also supported on the **final step of a Parallel transformer**:

- ``remainder`` (Optional, boolean): If ``true``, feed in all of the columns which have not been fed into other steps of the parallel transformer. This is especially useful in conjunction with the :class:`~ell.predictions.transformation.UnitTransformer` for passing through remaining features (or the label) unchanged. If specified, it must be the **only** key specified in the ``input`` specification.

.. _column_filter_object:

Column Filter Object
####################
This is the object which can be specified under ``include`` or ``exclude`` in the :ref:`transformer input specification <model_transformer_input_obj>`.

The following keys are supported:

- ``numericals`` (Optional, boolean): If ``true``, include numerical columns. This excludes the ``model.classifier.target`` column.
- ``categoricals`` (Optional, boolean or dict): If ``true``, include categorical columns. This excludes the ``model.classifier.target`` column. If a dict, it must have at least one of the following keys:

  - ``min_cardinality`` (number): Include categoricals with a cardinality higher than this value.
  - ``max_cardinality`` (number): Include categoricals with a cardinality lower than this value.

- ``columns`` (Optional, list of string): Explicit list of column names to include.
- ``target`` (Optional, boolean): If ``true``, include the ``model.classifier.target`` column.

.. _model_transformer_output_obj:

``output`` Object
*****************
This configures how to name the output columns of a transformer. Note that some transformers already name their output columns appropriately, so in that case, specifying ``column_names`` here is probably unnecessary. You can, however, still add a prefix or suffix.

Also note that the :class:`~ell.predictions.transformation.Series` transformer does not support the ``output`` key. Instead, specify the output names from the final step of that series.

The following keys are supported:

- ``column_names`` (Optional, list or dict): If a list, give the output columns the provided names. An error will be raised if the incorrect number of column names are specified. If a dict, it must have the following key:

  - ``keep_original`` (boolean): If ``true``, keep the original column names which were passed into the transformer. An error will be raised if the number of columns has changed during transformation.

- ``column_name_prefix`` (Optional, string): The prefix to add to the column names. An underscore will be added between this prefix and the column name.
- ``column_name_suffix`` (Optional, string): The suffix to add to the column names. An underscore will be added between the column name and this suffix.

Examples
++++++++
.. tabs::

    .. tab:: Single Model

        An single XGB model with no transformers:

        .. literalinclude:: /_examples/single_model.yml
            :language: yaml

    .. tab:: With Transformers

        An XGB model, one-hot-encoding some categorical features:

        .. literalinclude:: /_examples/model_with_transformers.yml
            :language: yaml

    .. tab:: Ensemble

        An averaging ensembler with the model ensembled 10 times, and setting the decision boundary such that it classifies approximately the top 2% of samples as positive:

        .. literalinclude:: /_examples/ensembled_model.yml
            :language: yaml

    .. tab:: Advanced Ensemble

        The same averaging ensembler with a custom label column, and explicit model timeouts and a compute budget specified:

        .. literalinclude:: /_examples/custom_label.yml
            :language: yaml