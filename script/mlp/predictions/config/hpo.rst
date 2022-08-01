Specifying HPO
==================

.. _hpo_obj:

``hpo`` Object
++++++++++++++++

The ``hpo`` section of the config consists of the following keys:

- ``algorithm`` (Required, string): The name of the HPO algorithm to use
- ``metric`` (Optional, string): The name of the metric that the HPO is trying to optimise. All fields of :class:`~ell.predictions.classification.Scores` are valid values (except ``confusion_matrix``). Defaults to ``gini_coefficient``.
- ``maximise`` (Optional, bool): If ``true`` the HPO tries to maximise the provided ``metric``. Defaults to ``true``.
- ``num_trials`` (Optional, int): The number of trials (sets of hyperparameters) to run. Either this parameter or ``duration`` **must** be provided. Defaults to infinite.
- ``duration`` (Optional, string): A timespec string (e.g. ``'2d6h'``) specifying the real time duration of the HPO. If specified the experiment will run until this time has elapsed, with no limit on the number of trials that are run in that time.

  .. note::
        Even if you just want to run HPO as long as possible, it is worth setting the ``duration`` to be less than the maximum job timeout for an HPO. This is because if ``duration`` is reached, the HPO can stop gracefully and write out all outputs, which is not possible if it is killed due to a timeout. A sensible buffer is twice the length of the longest a single model can take.

- ``num_parallel`` (Optional, int): The number of trials to run in parallel (either concurrently or in batches). A higher value will reduce the real world duration of the HPO experiment, but will decrease the performance, as the suggestion algorithm has fewer data points to work with before each trial. Defaults to 8.

- ``parameters`` (Optional, dict): Any keyword arguments to be passed to the HPO algorithm.

  - All HPO algorithms support the following parameters:

    - ``random_state`` (Optional, int): A random state used by the suggestion algorithm for reproducibility. ``seed`` is also accepted as an alias for this key. Defaults to 0.

  - All subclasses of :class:`~ell.predictions.hpo.RayAbstractTuner` support the following parameters:

    - ``num_initial_points`` (Optional, int): How many random trials to run before using the suggestion algorithm. A larger value helps prevent overfitting of the suggestion algorithm, and helps exlore more of the search space. Defaults to ``num_parallel``.
    - ``points_to_evaluate`` (Optional, list of dict): A list containing dictionaries, each of which specifies points within search space. These are initial parameters that are tried before the suggestion algorithm is used.  This is for when you already have some good parameters you want to run first to help the algorithm make better suggestions for future parameters. It can also be used for a "lukewarm" start, when we cannot truly warm start. The dictionaries must include every key in the search space, and the values for each key must be valid values given the search space specification.

- ``feature_select`` (Optional, bool or dict): If ``true`` the HPO will also optimise over the number of features to be included in the model. The number of features is selected uniformly from the interval ``[1, len(features)]``. If a dict, it must have at least one of the following keys:

  - ``min_features`` (Optional, int). The minimum number of features that could be included in the model. Defaults to 1.
  - ``max_features`` (Optional, int). The maximum number of features that could be included in the model. Defaults to ``len(features)``.

- ``space`` (Required, :ref:`space object <search_space_obj>`): Specification for the search space of the HPO.
- ``sample_sets`` (Optional, list of string): A list of MLSampler dataset names. If provided, each set of parameters will be run on each of the listed datasets. The returned result will be the results of each model aggregated by ``trial_aggregator``. The elements of the list are assumed to be suffixes, and are appended to ``train_`` and ``test_`` for each model.

  .. warning::
        Providing ``sample_sets`` multiplies the computational cost of each trial by the length of ``sample_sets``. For example, if ``num_trials = 100``, and ``sample_sets = ['set_1', 'set_2', 'set_3']``, a total of 300 models will be run (three for each trial). It is best to use caution when providing this parameter, to avoid running out of compute budget.

- ``trial_aggregator`` (Optional, string): The function used to combine multiple model results for a single set of hyperparameters. Only used when ``sample_sets`` is specified. The supported values are ``mean``, ``median``, ``min``, and ``max``. Defaults to ``mean``.

Some HPO algorithms support *warm starting* i.e. they can resume experimentation from a previous HPO run. All subclasses of :class:`~ell.predictions.hpo.RayAbstractTuner` support this behaviour. To make use of it, the following config key is available:

- ``warm_start`` (Optional, string): The runid of the previous HPO job to warm start from.

  .. warning::
        Care needs to be taken when warm starting to make sure the results from the previous run are applicable to the new experiment. You should make sure the two runs have the same dataset(s), and are optimising for the same metric. If you want to change the dataset or metric, consider the ``points_to_evaluate`` parameter instead.

In addition, all subclasses of :class:`~ell.predictions.hpo.RayAbstractTuner` support some additional keys. These control experiment wide early stopping, as well as the trial submission strategy. To make use of it, the following config key is available:

- ``early_stopping`` (Optional, dict): Configuration for early stopping of the HPO experiment. If enabled, this monitors the current list of top performing models, and stagnates if that list does not change. If the stagnation exceeds a patience level, then no more trials will be scheduled. The following sub-keys are supported:

  - ``patience`` (Required, int): The number of trials to wait before early stopping if no change in the top models has been observed.
  - ``num_top_models`` (Optional, int): The number of top models to consider. If none of these models has changed in ``patience`` trials, the HPO ends early. Defaults to 1.

  .. note::
        Early stopping deals with individual models, not batches. Because of this, it is often a good idea to set a value for ``patience`` that is larger than ``num_parallel``. This helps make sure that we do not stop the HPO too early due to noise within a batch.

- ``submission_strategy`` (Optional, str): One of ``eager`` or ``batch``. If ``eager``, a new trial will be submitted as soon as any of the currently running trials completes. If ``batch`` a new batch of trials will only be submitted once all trials in the previous batch have completed. Each HPO algorithm has a different default behaviour, please see the :ref:`HPO API Reference <hpo_api_ref>` for more details.

.. _search_space_obj:

``space`` Object
^^^^^^^^^^^^^^^^
The ``hpo.space`` section defines the search space of the HPO experiment. It allows you to optimise model parameters, as well as parameters anywhere in the full config. The ``space`` object is a dictionary that maps parameter names to :ref:`distribution objects <distribution_obj>`.

By default, keys are interpreted as the name of parameters in the ``model.classifier.parameters`` dictionary, and the values will be placed there. To have the HPO optimise over values in other locations in the full config, you can make use of `JSONPath <https://tools.ietf.org/id/draft-goessner-dispatch-jsonpath-00.html#name-overview-of-jsonpath-expres>`_ notation. Any key in the ``space`` dictionary starting with ``$.`` will be interpreted as a JSONPath, and its value will be inserted at the corresponding location in the config.

The ``space`` object also defines two special keys:

- ``num_features`` (Optional, :ref:`distribution object <distribution_obj>`): A specification for how many features to include in the model. If this key is provided, then the options provided for ``feature_select`` are ignored, and this distribution is used instead. This is useful if you want something other than a uniform distribution for the number of features selected.
- ``eta_k`` (Optional, :ref:`distribution object <distribution_obj>`): A special parameter that is interpreted and renamed to ``eta`` before it is inserted into the model config. The space object **must** also contain the ``n_estimators`` key. The value of ``eta`` to be inserted is calculated as follows:

  .. math::
    \texttt{eta} = \frac{\mathrm{min}(\texttt{n_estimators}, \texttt{eta_k})}{\texttt{n_estimators}}

.. _distribution_obj:

Distribution Object
*******************
The distribution object defines the distribution of a parameter that will be optimised by the HPO. Not all HPO algorithms support all possible distributions, but the config permits a number of options. The distribution object is a dictionary with one common key:

- ``distribution`` (Required, string): Defines what type of distribution the value of this parameter will be drawn from. The supported values are ``randint``, ``lograndint``, ``uniform``, ``loguniform``, ``choice``, ``normal``

The other keys within the object depend on the value of ``distribution``.

``randint``
###########
A uniform distribution of integers. The following keys are available:

- ``range`` (Required, list of int): The minimum and maximum value of the parameter. The value should be a two element list specifying the minimum and maximum value respectively. Both minimum and maximum values are *inclusive* i.e. values are sampled from the closed interval specified.
- ``step`` (Optional, int): A step that the sampled values will be rounded to. Both edges of the range need to be multiples of the step. This is useful when you want to sample from regularly spaced integers.

``lograndint``
##############
A loguniform distribution of integers. The following keys are available:

- ``range`` (Required, list of int): The minimum and maximum value of the parameter. The value should be a two element list specifying the minimum and maximum value respectively. Both minimum and maximum values are *inclusive* i.e. values are sampled from the closed interval specified.
- ``step`` (Optional, int): A step that the sampled values will be rounded to. Both edges of the range need to be multiples of the step. This is useful when you want to sample from regularly spaced integers.
- ``base`` (Optional, float): The base used for the loguniform distribution. Defaults to 10.

``uniform``
###########
A uniform distribution of floats. The following keys are available:

- ``range`` (Required, list of float): The range of values to sample from. The value should be a two element list specifying the minimum and maximum value respectively.
- ``step`` (Optional, float): A step that the sampled values will be rounded to. Both edges of the range need to be multiples of the step. This is useful when you want to sample from regularly spaced floats.

``loguniform``
##############
A loguniform distribution of floats. The following keys are available:

- ``range`` (Required, list of int): The minimum and maximum value of the parameter. The value should be a two element list specifying the minimum and maximum value respectively. Both minimum and maximum values are *inclusive* i.e. values are sampled from the closed interval specified.
- ``step`` (Optional, float): A step that the sampled values will be rounded to. Both edges of the range need to be multiples of the step. This is useful when you want to sample from regularly spaced floats.
- ``base`` (Optional, float): The base used for the loguniform distribution. Defaults to 10.

``choice``
##########
Values are sampled uniformly from a list of provided values. While mostly useful for categoricals, it can be used for all datatypes. The following keys are available:

- ``choices`` (Required, list): The list of values to choose from. Values are selected uniformly from this list, and the datatypes of the list are preserved.

``normal``
##########
A normal distribution of floats. The following keys are available:

- ``mean`` (Required, float): The mean of the normal distribution.
- ``std`` (Required, float): The standard deviation of the normal distribution.
- ``floor`` (Optional, float): The smallest acceptable value from the distribution. All values will be less than or equal to this. Can be used to prevent negative values from appearing.
- ``ceiling`` (Optional, float): The largest acceptable value from the distribution. All values will be less than or equal to this.


Examples
++++++++
.. tabs::

    .. tab:: Simple

        A simple :class:`~ell.predictions.hpo.TreeOfParzen` HPO that will run for 64 trials. 16 models will be run concurrently, and the algorithm will optimise for maximum ``gini_coefficient``.

        .. literalinclude:: /_examples/simple_hpo.yml
            :language: yaml

    .. tab:: Multiple Months

        An HPO run across multiple months. Each set of parameters will be run across 3 months, with the median value being used as the trial result. The number of features used by each model will be selected by the HPO, with a minimum value of 5.

        .. literalinclude:: /_examples/multiple_month_hpo.yml
            :language: yaml

    .. tab:: Advanced

        An HPO using many of the available config options. In particular this config makes use of the following:

        - Specifying algorithm parameters
        - Warm starting
        - Using a batching submission strategy
        - Early stopping
        - An experiment duration, rather than a specific number of trials
        - Manually including a ``num_features`` space specification
        - JSONPath injection of parameters

        .. literalinclude:: /_examples/advanced_hpo.yml
            :language: yaml