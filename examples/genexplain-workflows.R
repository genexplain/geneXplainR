##
## Demonstrating how to gather information about workflows and
## their parameters and how to invoke a workflow using R
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

## List of workflows

gx.ls("analyses/Workflows")
gx.ls("analyses/Workflows/Common")

## Workflow parameters
## There is no dedicated method to learn about the parameters of
## a specific workflow. A difference to analysis tools is that workflow parameter
## names need to be specified as they are shown in the graphical interface.
## In addition, one can obtain a 'listing' of the workflow to verify that the
## parameter names are used there as well. Note that the listing contains many
## other items like analysis tools used by the workflow and other 'nodes' of the
## workflow graph.

gx.ls("analyses/Workflows/Common/Find master regulators in networks (GeneWays)")

## The input is located in the Examples folder accessible to everyone.

input <- paste("data/Examples/TNF-stimulation of HUVECs GSE2639, Affymetrix HG-U133A microarray/",
               "Data/DEGs with limma/Normalized (RMA) DEGs with limma/Condition_1 vs. Condition_2/",
               "Up-regulated genes Ensembl",sep="")

## Invoking an analysis workflow
## Workflows need to be identified by their full path, because they may be located
## at various places of the workspace, e.g. within project or an Example folders and
## are not required to have unique names.

gx.workflow("analyses/Workflows/Common/Find master regulators in networks (GeneWays)",
                list("Input gene set"=input,Species="Human (Homo sapiens)","Results folder"=output),
                T,T);

## Loading results into local data tables

annotated.genes <- gx.get(paste(output,"/Regulator genes annot",sep=""))
regulators      <- gx.get(paste(output,"/Regulators Upstream 4",sep=""))

regulators[1:10,1:3]

## Exporting a network visualization to an image file
## To try this step, please replace <molecular network element> by the name of
## network visualization item in your result folder before running the 
## following command.
##
# gx.export(paste(output,"/<molecular network element>",sep=""),
#               exporter="Portable Network Graphics (*.png)",
#               target.file="geneXplain.png")

