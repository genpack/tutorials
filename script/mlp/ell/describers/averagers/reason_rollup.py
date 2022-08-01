"""
Takes a list of boxes (intended to be a list of a single box) and the reason map, and turns it into a customer ready
explanation. The reason map is a dict mapping a feature to a reason. If a feature appears, we check the reason map
for that feature and add the corresponding reason. Optionally, the reason map will include multiple reasons per
feature, for the feature being either in a certain value range, or a certain quartile range. Sometimes the map will
include the feature itself.

An example of such a map

{
'currentIR': 'They are a price sensitive customer',
'gainBySwitching': 'They can get a substantially better deal elsewhere',
'currentLoanTenure': 'They have been with us for {} months',
'flagDifResPostcodeAndSecPostcode': {1: 'They appear to be an interstate investor}',
'avgNumWebPageVisitsLast3Cycles': {'>1': 'They have been active on our website recently},
'avgSumOtherAcctLoansOtherCreditsLast3Cycles': {'<0.2': 'They have not been active on their loan account',
                                                '>1': 'They have been active on their loan account'},
'currentLoanOffsetBalanceClipped': {'>100': 'They have a reasonably large offset account'
                                    0: 'They have no offset account'},
'numOtherLoanAccounts': {0: 'They have no other loan accounts with us'}
}

Importances is a list of feature importances, and is optional. If it is passed, we use the importances to add or
subtract reasons until we hit precisely the num_reasons number of reasons.
"""

import copy
import locale
import logging
import operator
from datetime import datetime, timedelta
from typing import Union

import numpy as np

from .aggregator_abc import BoxAggregator

locale.setlocale(locale.LC_ALL, "")
LOGGER = logging.getLogger(__name__)


class ReasonRollup(BoxAggregator):
    def __init__(
        self,
        boxes,
        row,
        X,
        reason_map,
        manual_context=None,
        importances=None,
        num_reasons=3,
        encodings=None,
    ):
        """Class to "English" an explanation from a reason map

        Args:
            boxes: List of boxes to roll up
            row: 1-row DataFrame, row we are describing
            X: Dataset we used to fit the describers
            reason_map: A dict in the format described above
            manual_context: A hardcoded dictionary of englished explanations to include
            importances: A feature-importance describer output, for example Shap or LIME
            num_reasons: Number of reasons desired. A maximum, and if importances is defined, a minimum as well
            encodings: The cateorical encodings of the dataset to describe
        """
        row = row.to_frame().transpose()
        row.index.names = "caseID", "eventTime"
        super().__init__(boxes, row, X)
        self.reason_map = reason_map
        self.action_points = {}
        self.num_reasons = num_reasons
        self.importances = importances
        self.manual_context = manual_context
        self.encodings = encodings or {}

    def aggregate(self):
        """
        Create a customer ready explanation

        :returns: A list of explanations, one for each box. Each list is itself a list of strings
        """

        self.action_points = {}

        def format_reason(
            reason,
            feature,
            box,
            explanation,
            unformatted_explanation,
            row,
            *,
            decode=False,
        ):
            """
            Formats the reasons by rounding / day to year conversion etc.
            i.e. This loan is {} years old [sigfig] [day_to_year]

            :param reason: str or dict - Raw reason string to be formatted / dict containing all other info
            :param feature: str - name of feature to be used in map
            :param box: Not used?
            :param explanation: dict ???
            :param row: DataFrame - the row that needs a reason
            :param decode: bool - If true, the value is decoded with ``self.encodings``
            """
            if isinstance(reason, dict):
                added = check_reason_map(
                    list(reason.keys())[0],
                    box,
                    explanation,
                    unformatted_explanation,
                    reason,
                    row,
                )
            else:

                # The explanation string can include some tags at the end in []
                # So we need to get out a list of tags in each string, and then delete them from the string

                value = row[feature].iloc[0]
                if decode:
                    value = self._decode_value(feature, value)

                new_reason = reason[0]
                tags = new_reason.split("[")[1:]
                for tag in tags:
                    tag = tag.split("]")[0]

                    if tag.startswith("abs"):
                        value = abs(value)
                    elif tag.startswith("round"):
                        r = int(tag[-1])
                        value = round(float(value), r)
                    elif tag.startswith("sigfig"):
                        from math import log10, floor

                        # https://stackoverflow.com/questions/3410976/how-to-round-a-number-to-significant-figures-in-python
                        round_to_n = lambda x, n: round(
                            x, -int(floor(log10(x))) + (n - 1)
                        )
                        n = int(tag[-1])
                        if value != 0:
                            if value < 0:
                                value = -round_to_n(abs(value), n)
                            else:
                                value = round_to_n(value, n)
                        else:
                            value = 0
                    elif tag.startswith("day_to_month"):
                        value = value / 30.5
                    elif tag.startswith("month_to_year"):
                        value = value / 12
                    elif tag.startswith("day_to_year"):
                        value = value / 365.25
                    elif tag.startswith("currency"):
                        value = "${:,.0f}".format(abs(value))
                    elif tag.startswith("int"):
                        value = int(value)
                    elif tag.startswith("exact_date"):

                        # This is a bit of hack to get us to the last day of the month.
                        month_date = row.index.get_level_values("eventTime")[0]
                        month_date = month_date.replace(day=28) + timedelta(days=int(4))
                        month_date = month_date.replace(day=1) - timedelta(days=int(1))
                        value = month_date + timedelta(days=int(value))

                        if isinstance(value, np.datetime64):
                            value = value.astype(datetime)
                            if isinstance(value, (int, float)):
                                value = datetime.utcfromtimestamp(value * 1e-9)
                        value = value.strftime("%d %b %Y")
                    elif tag.startswith("expiry_adjustment"):
                        pass
                    else:
                        points = int(tag.split(" ")[1])
                        action = tag.split(" ")[0]
                        if action in self.action_points.keys():
                            self.action_points[action] += points
                        else:
                            self.action_points[action] = points

                unformatted = new_reason
                if "{}" in new_reason:
                    new_reason = new_reason.format(value)
                conv = reason[1]
                explanation.append(
                    str(new_reason + " [" + feature + "] [" + conv + "]")
                )
                unformatted_explanation.append(unformatted)
                added = True

            return added

        def check_reason_map(
            feature, box, explanation, unformatted_explanation, reason_map, row
        ):
            """
            Parsing reason map - interpreting boolean <= conditions per row

            :param feature: str - name of feature to be used in map
            :param box: Not used?
            :param explanation: dict ???
            :param reason_map: A dict in the format described at top of file
            :param row: DataFrame - the row that needs a reason
            """
            added = False
            if isinstance(reason_map[feature], list):
                added = format_reason(
                    reason_map[feature],
                    feature,
                    box,
                    explanation,
                    unformatted_explanation,
                    row,
                )
            elif isinstance(reason_map[feature], dict):
                for condition in reason_map[feature].keys():
                    condition = str(condition)

                    if condition.startswith("<") and not condition.startswith("<="):
                        compare_value = float(condition[1:])
                        if row[feature].iloc[0] < compare_value:
                            added = format_reason(
                                reason_map[feature][condition],
                                feature,
                                box,
                                explanation,
                                unformatted_explanation,
                                row,
                            )

                    elif condition.startswith(">") and not condition.startswith(">="):
                        compare_value = float(condition[1:])
                        if row[feature].iloc[0] > compare_value:
                            added = format_reason(
                                reason_map[feature][condition],
                                feature,
                                box,
                                explanation,
                                unformatted_explanation,
                                row,
                            )

                    elif condition.startswith(">="):
                        compare_value = float(condition[2:])
                        if row[feature].iloc[0] >= compare_value:
                            added = format_reason(
                                reason_map[feature][condition],
                                feature,
                                box,
                                explanation,
                                unformatted_explanation,
                                row,
                            )

                    elif condition.startswith("<="):
                        compare_value = float(condition[2:])
                        if row[feature].iloc[0] <= compare_value:
                            added = format_reason(
                                reason_map[feature][condition],
                                feature,
                                box,
                                explanation,
                                unformatted_explanation,
                                row,
                            )

                    elif condition.startswith("!="):
                        compare_value = float(condition[2:])
                        if row[feature].iloc[0] != compare_value:
                            added = format_reason(
                                reason_map[feature][condition],
                                feature,
                                box,
                                explanation,
                                unformatted_explanation,
                                row,
                            )

                    elif condition[0] in [
                        "0",
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        ".",
                    ]:
                        compare_value = float(condition)
                        if row[feature].iloc[0] == compare_value:
                            added = format_reason(
                                reason_map[feature][condition],
                                feature,
                                box,
                                explanation,
                                unformatted_explanation,
                                row,
                            )

                    # Check if condition is the decoded value of a categorical
                    elif condition in self.encodings.get(feature, {}).values():
                        try:
                            decoded = self._decode_value(feature, row[feature].iloc[0])
                        except KeyError:
                            pass
                        else:
                            if decoded == condition:
                                added = format_reason(
                                    reason_map[feature][condition],
                                    feature,
                                    box,
                                    explanation,
                                    unformatted_explanation,
                                    row,
                                    decode=True,
                                )

                    elif condition in row.columns:
                        added = format_reason(
                            reason_map[feature],
                            feature,
                            box,
                            explanation,
                            unformatted_explanation,
                            row,
                        )

            return added

        all_explanations = []
        unformatted_explanations = []
        added_features = []
        for box in self.boxes:
            explanation = []
            unformatted_explanation = []

            # Here we will loop over the manually created context
            if self.manual_context:
                for feature in self.manual_context.keys():
                    if feature in self.row.columns:
                        added = check_reason_map(
                            feature,
                            box,
                            explanation,
                            unformatted_explanation,
                            self.manual_context,
                            self.row,
                        )
                        if added:
                            added_features.append(feature)

                    else:
                        LOGGER.warning(
                            "Manual context feature {} not present in row".format(
                                feature
                            )
                        )

            # NOTE: There is an edge case here where things won't work properly. We want manual context features to
            # always go at the top, however in the case where we have a manual context feature but no rollup for that
            # particular value, and the same feature repeated in the box, the box check_reason_map will not trigger.

            for feature in box.keys():
                added = False
                if feature in self.reason_map.keys() and feature not in added_features:
                    added = check_reason_map(
                        feature,
                        box,
                        explanation,
                        unformatted_explanation,
                        self.reason_map,
                        self.row,
                    )
                if not added:
                    LOGGER.warning(
                        "Did not find a reason map for feature {} in box {}".format(
                            feature, box
                        )
                    )
                else:
                    added_features.append(feature)

            all_explanations.append(explanation)
            unformatted_explanations.append(unformatted_explanation)

        conversation = [None] * len(all_explanations[0])
        for explanation in all_explanations:
            for i, reason in enumerate(explanation):
                explanation[i] = reason.split("[")[0]
                conversation[i] = reason.split("[")[-1].split("]")[0]

        # TODO: Translate reasons into something more English
        # EG. "pricing" -> "Pricing Conversation"

        # Deduplicate explanations, since duplicates can appear but are not desired
        for i, (explanation, unformatted_explanation) in enumerate(
            zip(all_explanations, unformatted_explanations)
        ):
            duplicate_indices = []
            seen = set()
            for j, _explanation in enumerate(explanation):
                if _explanation in seen:
                    duplicate_indices.append(j)
                else:
                    seen.add(_explanation)

            for j in reversed(duplicate_indices):
                explanation.pop(j)
                unformatted_explanation.pop(j)
                conversation.pop(j)

        if self.importances:
            for i, (explanation, unformatted_explanation) in enumerate(
                zip(all_explanations, unformatted_explanations)
            ):
                importances = copy.deepcopy(self.importances)
                while len(explanation) < self.num_reasons:
                    feature = max(importances.items(), key=operator.itemgetter(1))[0]
                    _ = check_reason_map(
                        feature,
                        self.boxes[i],
                        explanation,
                        unformatted_explanation,
                        self.reason_map,
                        self.row,
                    )
                    del importances[feature]

        return all_explanations, unformatted_explanations, conversation

    def action(self):
        if self.action_points.get("price", 0) > 0:
            return "price"
        elif self.action_points.get("planning", 0) > 0:
            return "planning"
        elif self.action_points.get("life-event", 0) > 0:
            return "life-event"
        elif (
            self.action_points.get("loyalty", 0) > 0
        ):  # and (self.row['currentLoanTenure'] > 60 or self.row['currentBankTenure'] > 60):  # TODO: Check this
            # TODO: Anniversary vs loyalty rewards?
            return "loyalty"
        elif self.action_points.get("package", 0) > 0:
            return "package"
        else:
            return "service"

    def _decode_value(self, feature: str, value: Union[str, float, int]):
        """Try and get the decoded value from the encodings file.

        Since the datatype of the encoded value may not match the key in the encodings
        dictionary, we first try the string representation of the value. If that does
        not give a result, we try to cast the value to integer. If the cast fails, or
        the integer key does not exist within the dictionary we raise a KeyError.

        Args:
            feature: The feature the value is from
            value: The value to decode if possible

        Returns:
            The decoded value if it exists

        Raises:
            KeyError: If the value cannot be resolved as a key within the encodings
                dictionary for the feature.
        """
        # First we check if the string value is a key in the dictionary. This covers
        # cases where the dtype of the data and of the encodings are the same.
        if str(value) in self.encodings[feature]:
            return self.encodings[feature][str(value)]

        # If we could not find the string value directly, it could be because the value
        # is a double/float, but the encoded value is an integer. If we can cast to
        # int, we look for that integer in the encodings. If not, then the value cannot
        # correspond to a key, so we raise a KeyError.
        try:
            integral_value = int(value)
        except ValueError:
            raise KeyError(
                f"Could not find the encoded '{value}' in the encodings for {feature}",
            )

        return self.encodings[feature][str(integral_value)]
