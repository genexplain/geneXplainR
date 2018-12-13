#
# Copyright (c) 2018 geneXplain GmbH, Wolfenbuettel, Germany
# Author: Philip Stegmaier, philip.stegmaier@genexplain.com
#
# Runs TFBS analysis for all gene sets within specified folder
#
# Input table with parameters should consist of two tab-separated 
# key (left) and value (right) columns and no header with the following elements:
#
# +------------------+-------------------------------------------------------------------------+
# | user             | login user (default: empty)                                             |
# | password         | login password (default: empty)                                         |
# | server           | https://platform.genexplain.com                                         |
# | inputFolder      | platform path of input folder, required, no default                     |
# | inputRegex       | regular expression to filter folder contents for input files            |
# | noSet            | path of NO set, required, no default                                    |
# | profile          | PWM profile to use                                                      |
# | species          | species of gene sets in folder (default: Human (Homo sapiens) )         |
# | outputFolder     | folder for output (default: input folder)                               |
# | doSample	     | true or false to draw subsamples from the NO set (default: false)       |
# | sampleNum        | number of NO set samples (default: 5)                                   |
# | sampleSize       | size of NO set samples (default: 1000)                                  |
# | siteFeCutoff     | fold enrichment cutoff for sites (default: 1.0)                         |
# | siteFdrCutoff    | FDR cutoff for site enrichment (default: 1.0)                           |
# | seqFeCutoff      | fold enrichment cutoff for sequences with sites (default: 0.0)          |
# | seqFdrCutoff     | FDR cutoff for sequences with sites (default: 1.0)                      |
# +------------------+-------------------------------------------------------------------------+
#
library(geneXplainR)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
    stop("Please provide a file with configuration parameter table")
}
params <- read.table(args[1], header=F, sep="\t", row.names=1)
getParameter <- function(value, defaultVal) {
    V <- value
    if (is.na(value)) {
        V <- defaultVal
    }
    V
}
gx.login(as.character(params['server',1]),
         as.character(params['user',1]),
         as.character(params['password',1]))
folder <- getParameter(as.character(params['inputFolder',1]), "")
if (folder == "") {
    stop("Missing input folder, should start with 'data/Projects'")
}
regex  <- getParameter(as.character(params['inputRegex',1]), ".+")
noSet  <- getParameter(as.character(params['noSet',1]), "")
if (noSet == "") {
    stop("Missing noSet parameter")
}
species      <- getParameter(as.character(params['species',1]), "Human (Homo sapiens)")
profile      <- getParameter(as.character(params['profile',1]), "")
if (profile == "") {
    stop("Missing profile parameter")
}
fromTss       <- getParameter(as.numeric(as.character(params['from',1])), -1000)
toTss         <- getParameter(as.numeric(as.character(params['to',1])), 100)
outputPath    <- getParameter(as.character(params['outputPath',1]), folder)
outputName    <- getParameter(as.character(params['outputName',1]), "tfbs_analysis")
doSample      <- getParameter(as.logical(as.character(params['doSample',1])), "false")
sampleNum     <- getParameter(as.numeric(as.character(params['sampleNum',1])), 5)
sampleSize    <- getParameter(as.numeric(as.character(params['sampleSize',1])), 1000)
siteFeCutoff  <- getParameter(as.numeric(as.character(params['siteFeCutoff',1])), 1.0)
siteFdrCutoff <- getParameter(as.numeric(as.character(params['siteFdrCutoff',1])), 1.0)
seqFeCutoff   <- getParameter(as.numeric(as.character(params['seqFeCutoff',1])), 0.0)
seqFdrCutoff  <- getParameter(as.numeric(as.character(params['seqFdrCutoff',1])), 1.0)
des    <- grep(regex, gx.ls(folder), perl=T, value=T)
minYesSize <- 10
maxYesSize <- 1000
gx.createFolder(outputPath, outputName)
outputFolder <- paste0(outputPath,"/",outputName)
sapply(des, function(x) {
           dt <- gx.get(paste0(folder, "/", x))
           if (nrow(dt) >= minYesSize & nrow(dt) <= maxYesSize) {
               print(dt)
               gx.analysis("Search for enriched TFBSs (genes)", list(
                                                                     yesSetPath  = paste0(folder,"/",x),
                                                                     noSetPath   = noSet,
                                                                     profilePath = profile,
                                                                     species     = species,
                                                                     from        = fromTss,
                                                                     to          = toTss,
                                                                     doSample      = doSample,
                                                                     sampleNum     = sampleNum,
                                                                     sampleSize    = sampleSize,
                                                                     siteFeCutoff  = siteFeCutoff,
                                                                     siteFdrCutoff = siteFdrCutoff,
                                                                     seqFeCutoff   = seqFeCutoff,
                                                                     seqFdrCutoff  = seqFdrCutoff,
                                                                     output   = paste0(outputFolder,"/",x,"_Enriched_motifs")
                                                                     ), verbose=F)
           }
         })
