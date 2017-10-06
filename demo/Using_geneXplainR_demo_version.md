---
title: Using geneXplainR demo version
author: Luisa Peterson
date: 05 Oct 2017
output:
  pdf_document: default
  html_document: default
---
# Installation

In order to use the R client to the [geneXplain](http://platform.genexplain.com/bioumlweb/#) platform we need to install the geneXplainR package from the GitHub repository. That requires the installation of the devtools package beforehand.

```{R}
paste(install.packages("devtools"))
library(devtools)
install_github("genexplain/geneXplainR")
```

To get access to the just installed geneXplainR packages the geneXplain R needs to be open via the library

```{R}
library(geneXplainR)
```
---
# Login

In order to start the platform session you need to sign in using `gx.login`. Either you put in your username and password as the arguments or just leave them empty to use the platforms demo Version.

``` {R}
gx.login("https://platform.genexplain.com","", "")
```
---
# Overview

The command `gx.ls()` gets a list of contents a certain platform folder offers. To specify the output, we can add a path and just get the content of this specified folder. Here we see the topics of the database/GeneWays path in the platform.

```{R open files, echo=TRUE}
gx.ls("databases/GeneWays")
```

To get an overview about the available analysis tools and their parameters we use `gx.analysis.list()`.

```{R}
gx.analysis.list()
```

If settled on a certain tool, we can find out the required parameters using `gx.analysis.parameters(analysisName)`. Here we see the input parameters for the Venn diagrams tool. Every parameter comes with a short description.

```{R}
gx.analysis.parameters("Venn diagrams")
```
---
# Defining Input Parameter

As we already know the parameter in order to use the Venn diagrams tool, we can start defining them.

First of all, we choose the output path for our results on the platform.

```{R}
Output <- "data/Public/Data sets/Data/Test_123/test"
```

Since we need three input tables to use this particular tool, we could, for example, just randomly generate them

```{R}
randomTable <- data.frame(replicate(10,sample(0:100,10,rep = TRUE)))
```

Afterwards we can upload the table to the platform. By using `gx.put` the randomTable gets stored in the platform. With the help of `gx.get` this table gets printed out.

```{R}
gx.put(Output,randomTable)
gx.get(paste(Output, sep = ""))
```

Alternatively, we can use some example data the geneXplain platform offers:

```{R}
geneXplainDataTable <- paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/",
"Data/DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
"Downregulated probes annot", sep = "")
```

Other than that, we can import any table from local files or the internet. The `read.table()` command
will help here

```{R}
TableFromInternet <- read.table("https://www.ebi.ac.uk/arrayexpress/files/A-AFFY-19/A-AFFY-19.reporters.txt", header = TRUE)
```
---
# Using the analysis tool

To actually use the Venn diagrams analysis tool, we define some tables again. So that they will actually see dependencies. Here some more sample data from the geneXplain platform is used.

```{R}
Tbl1 <- paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/Data/",
"DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
"Downregulated Ensembl genes", sep = "")

Tbl2 <- paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/Data/",
"DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
"Non-changed Ensembl genes", sep = "")

Tbl3 <- paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/Data/",
"DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
"Upregulated Ensembl genes",sep = "")
```

Afterwards it is possible to execute the Venn diagrams tool. Either you use the `gx.vennDiagrams()` preset or create the Diagram with the help of `gx.analysis()`. The Diagram and the result tables get stored on the Platform.

```{R}
gx.vennDiagrams(table1Path = Tbl1,
                table2Path = Tbl2,
                table3Path = Tbl3,
                table1Name = "Downregulated Ensembl genes",
                table2Name = "Non-changed Ensembl genes",
                table3Name = "Upregulated Ensembl genes",
                output = Output,
                simple = T, wait = T, verbose = T)
```
----
# Export

To import the just created Diagram from the Platform, where it is now saved, to the R Console you can use gx.export.

Thereby `gx.exporters()` gives an overview about the exporters

```{R}
gx.exporters()
```

After you have found out about the needed exporter, you can use the `gx.export()` command to start the export into a local folder.

```{R}
Result_Diagramn <- gx.export(paste(Output,"/Diagram",sep = ""),
exporter = "Portable Network Graphics (*.png)",
target.file = "vennDiagrams_geneXplainII.png")
```