### examples.R -------------------------------
library(msaR)

# read some sequences from a multiple sequence alignment file and display
seqfile <- system.file("sequences","AHBA.aln", package="msaR")
msaR(seqfile)

