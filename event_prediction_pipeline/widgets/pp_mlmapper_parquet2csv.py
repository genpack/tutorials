######## Setup: ###############################

import sys
import os
import pandas as pd
from io import StringIO
from pandas.tseries.offsets import MonthEnd
import json
import yaml
from datetime import datetime

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.expand_frame_repr', False)
#pd.set_option('max_colwidth', -1)

def setdiff(first, second):
        second = set(second)
        return [item for item in first if item not in second]
        
######## Inputs: ###############################

ncolchunk = 200
master_config_path = 'D:/Users/nima.ramezani/Documents/CodeCommit/data-science-tools/R_Pipeline/master_config.yml'

with open(master_config_path) as mcf:
    mc = yaml.safe_load(mcf)

# Use these dates to filter down the mlmapper if required

min_date = datetime. strptime(mc['mlmapper_start_date'], '%Y-%m-%d').date()
max_date = datetime. strptime(mc['mlmapper_end_date'], '%Y-%m-%d').date()   


######## Set paths: ###############################
mlm_path  = mc['path_mlmapper'] + '/' + mc['mlmapper_id'][0:8] + '/data'
fet_path  = mc['path_mlmapper'] + '/' + mc['mlmapper_id'][0:8] + '/etc/' + 'features.json'
csv_path  = mc['path_mlmapper'] + '/' + mc['mlmapper_id'][0:8] + '/csv'

if not os.path.exists(csv_path):
    os.makedirs(csv_path)
    
with open(fet_path) as fetf:
    fet = json.load(fetf)
    
remaining_features = fet['features'] 

######## Remove existing features already copied as csv from the remaining features: ###############################
existing = []
listcsvs = os.listdir(csv_path)
for fn in listcsvs:
    tbl = pd.read_csv(csv_path + '/' + fn, header = None, nrows = 1)
    existing += tbl.iloc[0].tolist()
    
remaining_features = setdiff(remaining_features, existing)

if len(listcsvs) > 0:
    cnt = (max([int(v.replace('csv_', '').replace('.csv', '')) for v in listcsvs]))
else:
    cnt = 0
    
######## Run: ###############################
while len(remaining_features) > 0:
    cnt += 1
    ncol = min(len(remaining_features), ncolchunk)
    fets = remaining_features[0:ncol]
    fets.append('caseID')
    fets.append('eventTime')
    fets = list(set(fets))
    mldf = pd.read_parquet(mlm_path, columns = fets, engine = 'pyarrow')
    mldf[(mldf.eventTime > min_date) & (mldf.eventTime < max_date)].to_csv(csv_path + '/csv_' + str(cnt) + '.csv')
    remaining_features = setdiff(remaining_features, fets)
    
