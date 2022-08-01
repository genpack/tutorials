from typing import List, Optional

from ell.exceptions import EllException


class PredictionsException(EllException):
    pass


class DistributorException(PredictionsException):
    def __init__(
        self,
        *args,
        incomplete_runids: Optional[List[str]] = None,
        results: Optional[dict] = None
    ) -> None:
        self.incomplete_runids = incomplete_runids
        self.results = results
        super().__init__(*args)


class DistributorTimeoutError(DistributorException, TimeoutError):
    pass


class FarmedModelsFailed(DistributorException):
    pass


class DistributorComputeBudgetExhausted(DistributorException):
    pass
