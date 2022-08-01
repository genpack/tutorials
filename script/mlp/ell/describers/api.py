__all__ = ["describe"]

import functools
import logging

import pandas as pd
from ell.env.env_abc import AbstractEnv

from ell.predictions import utils as predutils
from . import compat, utils
from .aggregators import ReasonRollup
from .evaluator import ExplanationEvaluator
from .explanation import AbstractDescriber

LOGGER = logging.getLogger(__name__)


def describe(
    config: dict,
    run_path: str,
    attempt_number: int,
    partition_id: int,
    rows_uri: str,
    module_path: str,
    data_path: str,
    model_uri: str,
    env: AbstractEnv = compat.env,
) -> None:
    """Create an describer, describe the required rows, evaluate the
    explanations, then persist them.

    Args:
        config: Full describer config.
        run_path: Directory where the run's output files should be
            written to.
        attempt_number: Attempt number for this run.
        partition_id: Partition ID of this run.
        rows_uri: Directory or file-path where rows to describe are
            located.
        module_path: Directory where input dataset was predicted on
            (usually an infer modulerun).
        data_path: Directory where input datasets are located.
        model_uri: Directory or file-path where the pickled model is
            located.
        env: Environment to use.

    """
    LOGGER.info("Beginning explanation")

    run_path = predutils.ensure_uri(run_path, is_folder=True)
    rows_uri = predutils.ensure_uri(
        rows_uri, is_folder=not rows_uri.endswith(".parquet")
    )
    module_path = predutils.ensure_uri(module_path, is_folder=True)
    data_path = predutils.ensure_uri(data_path, is_folder=True)
    model_uri = predutils.ensure_uri(
        model_uri, is_folder=not model_uri.endswith(".pkl")
    )

    # Get the random seed
    random_seed = config.get("random_seed", 0)
    model = predutils.load_model(model_uri, env=env)

    sampled_folder = config["dataset"]["sampled"]["folder"]
    dataset_path = data_path.folder(sampled_folder)

    manual_context_cols = list(config.get("manual_context", {}).keys())
    LOGGER.debug("Manual context features", extra={"data": manual_context_cols})
    reason_map_cols = list(config.get("reason_map", {}).keys())
    LOGGER.debug("Reason map features", extra={"data": reason_map_cols})
    describer_cols = list(
        (set(manual_context_cols) | set(reason_map_cols)) - set(model.features)
    )

    loader_kwargs = dict(
        columns=[*model.features, *describer_cols],
        index_columns=["caseID", "eventTime"],
        env=env,
    )

    X_loader = predutils.ParquetDatasetLoader(dataset_path, **loader_kwargs)
    rows_loader = predutils.ParquetDatasetLoader(rows_uri, **loader_kwargs)
    with X_loader, rows_loader:
        X = X_loader.load()
        rows = rows_loader.load()

    encodings_uri = data_path.file("categorical_encodings.json")
    encodings = env.read_jsonish(encodings_uri)

    args = config["args"][attempt_number]
    args.setdefault("random_state", random_seed)
    LOGGER.debug("Describer arguments", extra={"data": args})

    if "evaluator_num_rows" in args:
        eval_x = X.sample(args["evaluator_num_rows"], random_state=random_seed)
        LOGGER.info("Downsampling X to {} for evaluation".format(X.shape))
    else:
        eval_x = X

    features = args.get("features", list(set(X.columns) & set(rows.columns)))
    LOGGER.debug("features", extra={"data": features})

    # The conditions under which we can re-use existing predictions are:
    # - The describer args contains “describer: limetree” AND
    # - The describers args does not contain “sampling: perturb”
    # All describers we have run in production to date jan 2021 satisfy these conditions.
    reuse_predictions = (
        args.get("reuse_predictions", True)
        and args.get("describer", None) == "limetree"
        and args.get("sampling", None) != "perturb"
    )
    if reuse_predictions:
        LOGGER.debug(
            "Using persisted predicted probabilities and categories for the Evaluator "
            "and Limetree model"
        )
        predictions_uri = module_path.folder("predictions").file("predictions.parquet")
        predictions_loader = predutils.ParquetDatasetLoader(
            predictions_uri, index_columns=["caseID", "eventTime"]
        )
        with predictions_loader:
            predictions_df = predictions_loader.load()
        persisted_data = utils.ReadFromPersisted(predictions_df)

        predict_or_get_probabilities = persisted_data.get_probabilities
        predict_or_get_categories = persisted_data.get_categories
    else:
        LOGGER.debug(
            "Run will recompute probabilities and categories for each row to describe"
        )

        predict_or_get_probabilities = functools.partial(
            utils.predict_probabilities, model
        )
        predict_or_get_categories = functools.partial(utils.predict_categories, model)

    _evaluator = ExplanationEvaluator(
        dataset=eval_x,
        predict_or_get_probabilities=predict_or_get_probabilities,
        predict_or_get_categories=predict_or_get_categories,
        encodings=encodings,
        exclude_categoricals=(
            config.get("exclude_categoricals") or args.get("exclude_categoricals", [])
        ),
        features=features,
    )
    _describer = AbstractDescriber.create(
        describer_name=args["describer"],
        X=X,
        encodings=encodings,
        predict_or_get_probabilities=predict_or_get_probabilities,
        predict_or_get_categories=predict_or_get_categories,
    )

    LOGGER.info("Describer loaded and initialised")

    mode = config["mode"]
    LOGGER.debug("mode: %s", mode)

    reason_map = config.get("reason_map")

    all_scores = []
    all_englishing = []
    all_explanations = []

    for (caseid, event_time), row in rows.iterrows():
        if mode == "list":
            box = _describer.describe(row, **args)[1]
        elif mode == "box":
            box = _describer.get_box(row, **args)
        else:
            raise NotImplementedError(mode)

        # Append scores
        scores = _evaluator.scores(box=box, row=row, features=features)
        scores["caseID"] = caseid
        scores["eventTime"] = event_time
        if utils.scores_meet_threshold(scores, config.get("score_thresholds", {})):
            scores["final"] = True
        else:
            scores["final"] = False
            LOGGER.debug(
                "Row doesn't meet score cutpoint: explanations and englishing will "
                "not be written out for it"
            )
        all_scores.append(pd.Series(scores))

        if not scores["final"]:
            continue

        # Append Englishing
        if reason_map:
            reason_rollup = ReasonRollup(
                boxes=[box],
                row=row,
                X=None,
                reason_map=reason_map,
                manual_context=config.get("manual_context"),
                encodings=encodings,
            )
            reasons, unformatted_reasons, conversations = reason_rollup.aggregate()
            if reasons:
                reasons = reasons[0]
                unformatted_reasons = unformatted_reasons[0]

            LOGGER.debug(
                "Reason lengths: reasons=%s, unformatted_reasons=%s, conversations=%s",
                len(reasons),
                len(unformatted_reasons),
                len(conversations),
            )
            for (
                explanation_number,
                (reason, unformatted_reason, conversation),
            ) in enumerate(zip(reasons, unformatted_reasons, conversations), start=1):
                all_englishing.append(
                    pd.Series(
                        {
                            "caseID": caseid,
                            "eventTime": event_time,
                            "explanation_number": explanation_number,
                            "unformatted_reason": unformatted_reason,
                            "reason": reason,
                            "conversation": conversation,
                        }
                    )
                )

        # `explanations` is in the form:
        # {
        #   feature 1: {upper: 123, lower: None, actual: 456},
        #   feature 2: {upper: None, lower: 789, actual: 101},
        #   ...
        # }
        # upper and lower can be None or floats. actual is always a
        # float.
        #
        # We want the resulting table of all CaseIDs and their
        # explanations to look like this:
        # caseID | eventTime | feature   | upper | lower | actual
        # -------------------------------------------
        # abc    | 2020-06   | feature 1 | 123   | None  | 456
        # abc    | 2020-06   | feature 2 | None  | 789   | 101
        # def    | 2020-06   | feature 1 | 234   | None  | 567
        # ...
        for explanation_number, (feature, values) in enumerate(box.items(), start=1):
            output_row = values.copy()
            output_row.update(
                {
                    "feature": feature,
                    "caseID": caseid,
                    "eventTime": event_time,
                    "explanation_number": explanation_number,
                }
            )
            all_explanations.append(pd.Series(output_row))

    df_explanations = pd.DataFrame(all_explanations)
    explanations_uri = (
        run_path.folder("explanations")
        .folder(f"attempt={attempt_number:02}")
        .file(f"part-{partition_id:05}.snappy.parquet")
    )
    utils.persist_explanations(df_explanations, explanations_uri, env)

    df_englishing = pd.DataFrame(all_englishing)
    englishing_uri = (
        run_path.folder("englishing")
        .folder(f"attempt={attempt_number:02}")
        .file(f"part-{partition_id:05}.snappy.parquet")
    )
    utils.persist_englishing(df_englishing, englishing_uri, env)

    df_scores = pd.DataFrame(all_scores)
    scores_uri = (
        run_path.folder("scores")
        .folder(f"attempt={attempt_number:02}")
        .file(f"part-{partition_id:05}.snappy.parquet")
    )
    utils.persist_scores(df_scores, scores_uri, env)
