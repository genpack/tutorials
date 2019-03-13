library(reticulate)

life <- import('lifelines')


#from lifelines.datasets import load_rossi
#from lifelines import CoxPHFitter

rossi_dataset = life$datasets$load_rossi()


cph = life$CoxPHFitter()
cph$fit(rossi_dataset, 'week', event_col = 'arrest', strata = 'race', show_progress = T)

cph$print_summary()  # access the results using cph.summary

"""
<lifelines.CoxPHFitter: fitted with 432 observations, 318 censored>
      duration col = 'week'
         event col = 'arrest'
            strata = ['race']
number of subjects = 432
  number of events = 114
    log-likelihood = -620.56
  time fit was run = 2019-01-27 23:08:35 UTC

---
      coef  exp(coef)  se(coef)     z      p  -log2(p)  lower 0.95  upper 0.95
fin  -0.38       0.68      0.19 -1.98   0.05      4.39       -0.75       -0.00
age  -0.06       0.94      0.02 -2.62   0.01      6.83       -0.10       -0.01
wexp -0.14       0.87      0.21 -0.67   0.50      0.99       -0.56        0.27
mar  -0.44       0.64      0.38 -1.15   0.25      2.00       -1.19        0.31
paro -0.09       0.92      0.20 -0.44   0.66      0.60       -0.47        0.30
prio  0.09       1.10      0.03  3.21 <0.005      9.56        0.04        0.15
---
Concordance = 0.64
Likelihood ratio test = 109.63 on 6 df, -log2(p)=68.48
"""

cph$baseline_cumulative_hazard_ %>% dim
