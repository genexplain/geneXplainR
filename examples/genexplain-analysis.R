##
## Demonstrating how to gather information about the tools and
## their parameters and how to invoke a platform tool using R
##
## Please specify server, username and password as well 
## as the output path as commandline arguments
##
args <- commandArgs(trailingOnly = TRUE)
gx.server <- args[1]
gx.user   <- args[2]
gx.passwd <- args[3]

## This is the output path, e.g. 'data/Projects/<my_project>/Data/<my_folder>/<output>',
## where <my_project>, <my_folder> and <output> need to replaced with actual
## values and the project and the folder need to exist.

output <- args[4]

## Loading library and login using specified credentials

library(geneXplainR)
gx.login(gx.server, gx.user, gx.passwd)

## List of available analysis tools

gx.analysis.list()

## Parameters for a selected analysis tool.
## This step is important to learn about the tool parameters.

gx.analysis.parameters("Functional classification");

## The input is located in the Examples folder accessible to everyone.

input <- paste("data/Examples/TNF-stimulation of HUVECs GSE2639, Affymetrix HG-U133A microarray/",
               "Data/DEGs with limma/Normalized (RMA) DEGs with limma/Condition_1 vs. Condition_2/",
               "Up-regulated genes Ensembl",sep="")

## Invoking the analysis using the gx.analysis function
## Parameters are usually specified as a list. One can use the graphical interface
## to collect the proper inputs for parameters like species or bioHub.

gx.analysis("Functional classification",list(sourcePath=input, 
                                                 species="Human (Homo sapiens)", 
                                                 bioHub="GO (biological process)",
                                                 minHits=2,
                                                 pvalueThreshold=0.01,
                                                 outputTable=output));

## In this case the result is a table which R can easily extract into
## a data table

result <- gx.get(output)

## From here the result table can be processed within your R workspace, or written to disk.
