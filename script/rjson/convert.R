###### Package: rjson ========================
### convert.R -----------------------------
dataset <- read.csv("C:/Nicolas/RCode/projects/tutorials/rjson/data/Data_DISCHARGES_Exceptions_Working_File.csv")

fail = c(706,5141, 12491, 13745:13748, 25244)
a = jsonlite::fromJSON(paste0('[', dataset$data[- fail] %>% paste(collapse = ','), ']'), flatten = T)

for(i in names(a)){if(inherits(a[,i],'list')){a[,i] <- NULL}}

write.csv(a, 'converted.csv')

###### Package: rook:

### exampleWithGoogleVis:
require(Rook)
require(googleVis)
s <- Rhttpd$new()
s$start(listen='127.0.0.1')

my.app <- function(env){
  ## Start with a table and allow the user to upload a CSV-file
  req <- Request$new(env)
  res <- Response$new()
  
  ## Provide some data to start with
  ## Exports is a sample data set of googleVis
  data <- Exports[,1:2] 
  ## Add functionality to upload CSV-file
  if (!is.null(req$POST())) {
    ## Read data from uploaded CSV-file
    data <- req$POST()[["data"]]
    data <- read.csv(data$tempfile)
  }
  ## Create table with googleVis
  tbl <- gvisTable(data, 
                   options=list(gvis.editor="Edit me!",
                                height=350),
                   chartid="myInitialView")
  ## Write the HTML output and
  ## make use of the googleVis HTML output.
  ## See vignette('googleVis') for more details
  res$write(tbl$html$header) 
  res$write("<h1>My first Rook app with googleVis</h1>")
  res$write(tbl$html$chart)
  res$write('
            Read CSV file:<form method="POST" enctype="multipart/form-data">
            <input type="file" name="data">
            <input type="submit" name="Go">\n</form>')            
  res$write(tbl$html$footer)
  res$finish()
}
s$add(app=my.app, name='googleVisTable')


## Open a browser window and display the web app
s$browse('googleVisTable')
