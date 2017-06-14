##
## Example workflow analysis
##
## Identify enriched motifs in promoters (GTRD)
## 
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

profile <- "databases/TRANSFAC(R) (public)/Data/profiles/vertebrates"

species <- "Human (Homo sapiens)"

gx.workflow("analyses/Workflows/GTRD/Identify enriched motifs in promoters (GTRD)",
                list("Input Yes gene set" = yesInput, 
                     "Input No gene set"  = noInput, 
                     Profile              = profile,
                     Species              = species, 
                     "Result folder"      = output),
                T,T)

gx.get(paste(output,"/Enriched motifs",sep=""))

