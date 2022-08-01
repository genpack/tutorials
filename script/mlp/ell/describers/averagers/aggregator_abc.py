"""
Aggregators perform operations on the list of produced boxes after the boxes have been produced by the describers.
These could be choosing the best box, creating an ensemble box, or translating the box into a customer ready explanation,
or anything similar. Aggregators have access to the list of boxes, the row, the sample, and other parameters. At this
stage, they do not have access to the model. All aggregators return a list, often a list of boxes but not always. If
you are going to chain together multiple aggregators, make sure the output of the earlier one satisfies the requirements
of the 'boxes' parameter of the later one.
"""

from abc import ABC


class BoxAggregator(ABC):
    boxes = None

    def __init__(self, boxes, row, X, **params):
        self.boxes = boxes
        self.row = row
        self._X = X

    def aggregate(self):
        pass
