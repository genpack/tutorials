"""
A box ensembling method. For each box passed in, we break down that box into a list of distinct rules. Each "upper"
boundary can become a rule, and each "lower" boundary can become a rule. We then start with an empty box, and add rules.
At each step we add a rule, and see the improvement in our metric. We take the rule that improves us the most, and
repeat until the metric stops improving or we get more than our max_reasons.
"""


import copy
import locale
import logging

import numpy as np

from .aggregator_abc import BoxAggregator
from ..evaluator import ExplanationEvaluator

locale.setlocale(locale.LC_ALL, "")
LOGGER = logging.getLogger(__name__)


class EnsembleBox(BoxAggregator):
    def __init__(
        self,
        boxes,
        row,
        X,
        predict_probabilities_fn,
        predict_categories_fn,
        encodings=None,
        max_reasons=None,
        metric="fidelity",
        features=None,
        exclude_categoricals=None,
    ):
        """

        :param boxes: List of boxes that we are going to ensemble
        :param row: 1-row DataFrame
        :param X: Dataset on which to optimise the box
        :param predict_probabilities_fn:
        :param predict_categories_fn:
        :param encodings: categorical_encodings associated with X
        :param max_reasons: The maximum size of the box allowable
        :param metric: Name of the metric to optimise, defaults to 'fidelity'
        :param features: List of features to use for describing and evaluating
        :param exclude_categoricals: List of categoricals to leave undummified, to avoid dimensionality. e.g. Postcode
        """
        super().__init__(boxes, row, X)

        self.metric = metric
        self.max_reasons = max_reasons
        self.boxes = boxes
        self.predict_probabilities_fn = predict_probabilities_fn
        self.predict_categories_fn = predict_categories_fn
        self.encodings = encodings
        self.features = features
        self.exclude_categoricals = exclude_categoricals

    def aggregate(self):
        """
        Create an ensemble box by the method described above

        :returns: A single box
        """

        final_box = {}
        evaluator = ExplanationEvaluator(
            self._X,
            self.predict_probabilities_fn,
            self.predict_categories_fn,
            self.encodings,
            exclude_categoricals=self.exclude_categoricals,
        )

        # Generate a list of all rules

        rule_list = []
        for box in self.boxes:
            for feature in box.keys():
                if box[feature]["upper"] is not None:
                    rule_list.append({feature: {"upper": box[feature]["upper"]}})
                if box[feature]["lower"] is not None:
                    rule_list.append({feature: {"lower": box[feature]["lower"]}})

        def add_rule(box, rule):
            box = copy.deepcopy(box)
            feature = list(rule.keys())[0]
            if feature not in box.keys():
                box[feature] = {"upper": None, "lower": None}

            if "upper" in rule[feature].keys():
                if box[feature]["upper"] is None:
                    box[feature]["upper"] = rule[feature]["upper"]
                else:
                    box[feature]["upper"] = min(
                        box[feature]["upper"], rule[feature]["upper"]
                    )
            elif "lower" in rule[feature].keys():
                if box[feature]["lower"] is None:
                    box[feature]["lower"] = rule[feature]["lower"]
                else:
                    box[feature]["lower"] = max(
                        box[feature]["lower"], rule[feature]["lower"]
                    )

            box[feature]["actual"] = float(self.row[feature].values[0])

            return box

        # Rule searching
        improvement = 1
        score = 0
        while improvement > 0 and len(final_box.keys()) < self.max_reasons:

            score_improvement = [None] * len(rule_list)
            # Add each possible next rule
            for i, rule in enumerate(rule_list):

                new_box = add_rule(final_box, rule)

                new_score = evaluator.scores(new_box, self.row, self.features)[
                    self.metric
                ]

                score_improvement[i] = new_score - score

            best_index = np.argmax(score_improvement)
            improvement = score_improvement[best_index]
            score += improvement

            final_box = add_rule(final_box, rule_list[best_index])

            del rule_list[best_index]

        return [final_box]
