"""
The :mod:`ell.predictions.distributing`  module provides distributors for all
techstacks (namelay AWS and local) to :meth:`~AbstractDistributor.distribute` (starting additional
model jobs) and :meth:`~AbstractDistributor.collect_modules` (await and retrieve
all results). :meth:`~AbstractDistributor.distribute` enables the user to submit additional
train jobs (as specified per config) in parallel. This call is of short duration
and returns a UUID as reference. :meth:`~AbstractDistributor.collect_modules` provides a simple
call to await all specified training jobs to finish and returns a dict of all scores.
"""
__all__ = ["AbstractDistributor", "AWSDistributor", "LocalDistributor"]

from .aws_distributor import AWSDistributor
from .distributor_abc import AbstractDistributor
from .local_distributor import LocalDistributor
