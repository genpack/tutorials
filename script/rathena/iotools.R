# iotools.R

pyathena = reticulate::import('pyathena')
panda    = reticulate::import('pandas')

read_s3.sparklyr = function(path){
  sc <- sparklyr::spark_connect(master = 'local')
  el <- sparklyr::spark_read_csv(sc, name = 'el', path = path)
  return(el)
}

buildAthenaConnection = function(bucket = "s3://aws-athena-query-results-192395310368-ap-southeast-2"){
  pyathena$connect(s3_staging_dir = bucket, region_name = 'ap-southeast-2')
}

read_s3.athena = function(con, query){
  pandas$read_sql(query, con)
}

buildAthenaDataset = function(conn, dsName = 'dataset'){
  cursor = conn$curser()
  qry    = paste("CREATE DATABASE", dsName)
  cursor$execute(qry)
}

buildAthenaTable = function(conn, dsName, tblName, s3_data_path, drop_if_exists = T){}



  