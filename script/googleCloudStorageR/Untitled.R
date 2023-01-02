library(magrittr)

# https://cran.r-project.org/web/packages/googleCloudStorageR/vignettes/googleCloudStorageR.html

# install.packages("googleCloudStorageR")
library(googleCloudStorageR)
gcs_setup()


## Load googleCloudStorageR and gargle
library(gargle)

## Fetch token. See: https://developers.google.com/identity/protocols/oauth2/scopes
scope <-c("https://www.googleapis.com/auth/cloud-platform")
token <- token_fetch(scopes = scope)

## Pass your token to gcs_auth
gcs_auth(token = token)

## Perform gcs operations as normal
proj <- "scg-dai-sci-dev"

## get bucket info
buckets <- gcs_list_buckets(proj)
bucket <- "mediascreen_gapfill"
bucket_info <- gcs_get_bucket(bucket)
bucket_info

objects = gcs_list_objects(bucket = "mediascreen_gapfill")
segment-scores = objects$name %>% rutils::charFilter('segment_scores.csv', '10') %>% gcs_get_object(bucket = bucket)

objects$name %>% rutils::charFilter('segment_scores.csv', '10') %>% 
  gcs_get_object(bucket = bucket, saveToDisk = "standard_segmentation/reports/segment_scores.csv")

bigreadr::fread2('standard_segmentation/reports/segment_scores.csv') -> sc
sc %>% dplyr::arrange(AlwaysOnTrend) %>% head(1000) %>% View

nrow(sc) %>% sequence %>% sample(size = 30000, replace = F) -> sc_sample_index
sc[sc_sample_index, ] -> scs

plot(scs$AlwaysOnTrend, scs$SpecificNeed)
sum(scs$AlwaysOnTrend > 0.001 & scs$AlwaysOnTrend < 0.999)/nrow(sc)

sum(sc$SpecificNeed > 0.3 & sc$SpecificNeed < 0.7)/nrow(sc)

hist(sc$SpecificNeed)


sc$SpecificNeed[sc$SpecificNeed < 0.26] %>% hist(breaks = 1000)
sc$AlwaysOnTrend[sc$AlwaysOnTrend < 0.001] %>% hist(breaks = 1000)
sc$AlwaysOnTrend[sc$AlwaysOnTrend < 0.001] %>% length



objects$name %>% rutils::charFilter('awm.csv', '10') %>% 
  gcs_get_object(bucket = bucket) -> awm


objects$name %>% rutils::charFilter('awm.csv', '10') %>% 
  gcs_get_object(bucket = bucket, saveToDisk = "standard_segmentation/reports/segment_weights.csv")
awm = read.csv("standard_segmentation/reports/segment_weights.csv")

awm %<>% rutils::column2Rownames('X') %>% t
View(awm)


read.csv("standard_segmentation/configs/awm.csv") -> awm0
awm0 %<>% rutils::column2Rownames('X') %>% t
View(awm0)
