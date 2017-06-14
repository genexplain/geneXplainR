##
## Example workflow analysis
##
## Upstream analysis (TRANSFAC(R) and TRANSPATH(R))
## 
## This script requires subscriptions for TRANSFAC(R) and
## TRANSPATH(R)
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
## values and the project, the folder needs to exist and "output" can be created.

output <- args[4]

library(geneXplainR)
gx.login(gx.server, gx.user, gx.passwd)

yesInput <- paste("data/Examples/",
                  "TNF-stimulation of HUVECs GSE2639, Affymetrix HG-U133A microarray/",
                  "Data/DEGs with limma/Normalized (RMA) DEGs with limma/",
                  "Condition_1 vs. Condition_2/Up-regulated genes Ensembl",
                  sep="")

noInput <- paste("data/Examples/",
                 "TNF-stimulation of HUVECs GSE2639, Affymetrix HG-U133A microarray/",
                 "Data/DEGs with limma/Normalized (RMA) DEGs with limma/",
                 "Condition_1 vs. Condition_2/Non-changed genes Ensembl",
                 sep="")

profile <- "databases/TRANSFAC(R) 2017.1/Data/profiles/vertebrate_human_p0.01_non3d"

species <- "Human (Homo sapiens)"

gx.workflow("analyses/Workflows/TRANSPATH/Upstream analysis (TRANSFAC(R) and TRANSPATH(R))",
                list("Input Yes gene set" = yesInput, 
                     "Input No gene set"  = noInput, 
                     Profile              = profile,
                     Species              = species,
                     "Start of promoter"  = -1000,
                     "End of promoter"    = 100,
                     "Results Folder"     = output),
                T,T)

# Here we get two output tables which can be further analyzed.

transcription.factors <- gx.get(paste(output,"/Transcription factors annot",sep=""));
master.regulators     <- gx.get(paste(output,"/Master regulators annotated",sep=""));

