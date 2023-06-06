# copy_source.R
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/io_tools.R')


for (sf in mc$source_folders){
  "aws s3 cp s3://source.prod.st.%s.elservices.com/upload=%s/ %s/ --recursive --profile %s" %>% 
    sprintf(mc$client, sf, mc$path_original, mc$aws_profile) %>% shell
}