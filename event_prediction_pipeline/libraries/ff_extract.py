# packages
import os
import pandas as pd
import sys
import getpass
from st_api_client import StAPIClient

os.environ["AWS_PROFILE"] = f"write@{os.environ.get('client_name')}-st"

# Functions

def get_standard_feature_info(feature_factory, all_features: list):
    sfs = {f.Name: f for f in feature_factory._store.standard_features}
    periodics = {}
    impossible_to_find = []
    for feature in all_features:
        is_found=False
        feature_split = feature.split("_")
        for i in range(len(feature_split), 0, -1):
            curr = "_".join(feature_split[:i])
            if curr in sfs:
                #             print(curr)
                periodics[feature] = sfs[curr]
                is_found=True
                break
        if not is_found:
            impossible_to_find.append(feature)
    print(f'Impossible to find: {set(impossible_to_find)}')
    return periodics

def ff_to_df(features: dict):
    series = []
    for name, feat in features.items():
        info = {
            "name": name,
            "periodic_name": feat.Name,
            "description": feat.Description,
            "input_table": feat.Input_Table,
            "input_not_null": feat.Input_Not_Null,
            "input_columns": str(sorted(set(feat.Input_Columns))),
            "value": feat.Value,
            "filter": feat.Filter,
            "transformations": feat.Transformations,
            "groupby": feat.Group_By,
            "aggregation": feat.Aggregation,
            "time_conversion": feat.Time_Conversion,
            "encoding": feat.Encoding,
            "value_increased": feat.ValueIncreased,
            "value_decreased": feat.ValueDecreased,
            "value_changed": feat.ValueChanged,
            "loan_obs_started": feat.LoanObservationStarted,
            "pass_through": feat.PassThrough,
            "directional_fill": feat.Directional_Fill,
            "fill_value": feat.Fill_Value,
            "current": feat.Current,
            "inc_count": feat.Inc_Count,
            "dec_count": feat.Dec_Count,
            "change_count": feat.Change_Count,
            "num": feat.Num,
            "sum": feat.Sum,
            "mv_avg": feat.Moving_Average,
            "time_since": feat.Time_Since,
            "lag": feat.Lag,
            "auto_diff": feat.Auto_Diff,
            "auto_divide": feat.Auto_Divide
        }
        series.append(pd.Series(info))

    return pd.DataFrame(series)
