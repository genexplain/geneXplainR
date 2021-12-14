## ----eval=FALSE----------------------------------------------------------
#  library(geneXplainR)
#  # Words within placeholders (<...>) need to be replaced.
#  gx.login("<server>","<user>","<password>")

## ----eval=FALSE----------------------------------------------------------
#  gx.logout()

## ----eval=FALSE----------------------------------------------------------
#  #... after login
#  # Get the list of available tools
#  gx.analysis.list()
#  
#  # Show parameters for a specific tool
#  gx.analysis.parameters("Convert table")
#  
#  # Invoke an analysis with the tool
#  gx.analysis("Convert table", list(sourceTable = "data/Projects/Example/Data/example_table",
#                                    species     = "Human (Homo sapiens)",
#                                    sourceType  = "Genes: Ensembl",
#                                    targetType  = "Genes: Gene symbol",
#                                    outputTable = "data/Projects/Example/Data/example_output_table"))

## ----eval=FALSE----------------------------------------------------------
#  #... after login
#  # Get list of workflows in 'Common'
#  gx.ls("analyses/Workflows/Common")
#  
#  # Get parameters for specific workflow
#  gx.ls("analyses/Workflows/Common/Gene set enrichment analysis (Gene table)")
#  
#  # Invoke workflow
#  gx.workflow("analyses/Workflows/Common/Gene set enrichment analysis (Gene table)",
#              list("Input table"              = "data/Projects/Example/Data/example_table",
#                   "Enrichment Weight Column" = "Column name",
#                   "Species"                  = "Mouse (Mus musculus)",
#                   "Results folder"           = "data/Projects/Example/Data/example_output"))

## ------------------------------------------------------------------------
library(geneXplainR)
?gx.vennDiagrams

## ----eval=FALSE----------------------------------------------------------
#  #... after login
#  # Words in placeholders (<...>) need to be replaced with suitable values.
#  gx.put("data/Projects/<project name>/Data/<destination folder>", data)
#  data <- gx.get("data/Projects/<project name>/Data/<source folder>/<platform table>")

## ----eval=FALSE----------------------------------------------------------
#  #... after login
#  # Words in placeholders (<...>) need to be replaced with suitable values.
#  gx.importers()
#  gx.import.parameters("data/Projects/<project name>/Data/<destination folder>", "<importer name>")
#  gx.import("<local file>", "<platform destination path>", "<importer>", list("<parameter>"="<value>"))

## ----eval=FALSE----------------------------------------------------------
#  #... after login
#  # Words in placeholders (<...>) need to be replaced with suitable values.
#  gx.exporters()
#  gx.export.parameters("data/Projects/<project name>/Data/<item to export>", "<exporter name>")
#  gx.export("<platform item>", "<exporter>", list("<parameter>"="<value>"), "local file")

