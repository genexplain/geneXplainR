#########################
#
# Author: Luisa Peterson
# 2017/10/04
#
#########################
cat("Using geneXplainR - DEMO Version")
Sys.sleep(7)
cat("LOGIN")
Sys.sleep(7)

cat("Before using the R client to the geneXplain platform the geneXplainR package needs to be installed")

Sys.sleep(7)

#paste(install.packages("devtools"))
#library(devtools)
#install_github("genexplain/geneXplainR")

cat("When geneXplainR is installed it needs to be opend using the geneXplainR library: library(geneXplainR)")

Sys.sleep(7)

library(geneXplainR)

cat("OVERVIEW")
Sys.sleep(7)

cat("In order to start the platform session you need to sign in using gx.login:
gx.login(server='https://platform.genexplain.com', user='', password='') \nthe arguments 'user' and 'password' remain empty")

gx.login("https://platform.genexplain.com", "", "")

Sys.sleep(7)

cat("With gx.ls() you can get a list of contents the platform folder offers. 
To specify the output, add a path and just get the contest of this specified folder")

Sys.sleep(7)

gx.ls("databases/GeneWays")

cat("Here the top folders of the GeneWays databases were opened")

Sys.sleep(10)

cat("To find out about the available analysis tools and their parameters use gx.analysis.list()")

Sys.sleep(7)

gx.analysis.list()

Sys.sleep(7)

cat("If you have setteled on a certain tool you can find out the required parameters using gx.analysis.parameters(analysisName)",
    "for example the 'Venn diagrams'-tool: gx.analysis.parameters('Venn diagrams')")

Sys.sleep(7)

gx.analysis.parameters("Venn diagrams")

Sys.sleep(7)

cat("DEFINING INPUT PARAMETERS")
Sys.sleep(7)

cat("Find an output folder for your results")
Output <- "data/Public/Data sets/Data/Test_123/test"

cat("Since you need three input tables to use this particular tool, you could, for example just randomly generete them")
randomTable<-data.frame(replicate(10,sample(0:100,10,rep=TRUE)))

Sys.sleep(7)

cat("Aterwards the table you can upload te table to the platform. \nBy using gx.put the randomTable gets stored in the platform.
By using gx.get this table gets printed out to the console")

Sys.sleep(7)

gx.put(Output,randomTable)
gx.get(paste(Output, sep = ""))

Sys.sleep(5)

cat("Alternatively, you can use some example data the geneXplain platform offers")

geneXplainDataTable < -paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/",
"Data/DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
"Downregulated probes annot", sep = "")

Sys.sleep(7)

cat("Other than that, you can import any table from local files or the internet. Therefore you need to use the read.table command")

TableFromInternet <- read.table("https://www.ebi.ac.uk/arrayexpress/files/A-AFFY-19/A-AFFY-19.reporters.txt", 
                                        header = TRUE)

cat("USING THE ANALYSIS TOOL")
Sys.sleep(7)

cat("Now choose three tables you actually want to use for your Venn diagams.") 

Sys.sleep(7)

cat("This might look like this:
    Tbl1 <- paste('path_to_table', sep='')")

Sys.sleep(7)

Tbl1 <- paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/Data/",
              "DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
              "Downregulated Ensembl genes", sep = "")

Tbl2 <- paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/Data/",
              "DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
              "Non-changed Ensembl genes", sep = "")

Tbl3 <- paste("data/Examples/Atherosclerosis GSE6584, Illumina HumanRef-8v1 beadarray/Data/",
              "DEP treated cells/Experiment normalized (Differentially expressed genes Illu)_2_4_edited/",
              "Upregulated Ensembl genes",sep = "")

cat("Afterwards it is possible to execute the Venn diagrams tool.
    Either you use the gx.vennDiagrams() preset or create the Diagram with the help of gx.analysis().
    Arguments for gx.analysis and gx.vennDiagrams are definded in the Documentation of the packege.
    The Diagram and the result tables get stored on the Platform (Outputpath)")

Sys.sleep(12)

gx.vennDiagrams(table1Path = Tbl1,
                table2Path = Tbl2,
                table3Path = Tbl3,
                table1Name = "Downregulated Ensembl genes",
                table2Name = "Non-changed Ensembl genes",
                table3Name = "Upregulated Ensembl genes",
                output = Output,
                simple = T, wait = T, verbose = T)

cat("To import the just created Diagram from the Platform to the R Console you can use gx.export")

Sys.sleep(7)

cat("Thereby gx.exporters() gives an overview about the exporters") 
gx.exporters()

Sys.sleep(10)

cat("After you have found out about the needed importers and parameters, you can use the gx.export() command")

Result_Diagramn <- gx.export(paste(Output,"/Diagram",sep=""),
                             exporter = "JPEG file (*.jpg)",
                             target.file = "vennDiagrams_geneXplainR.jpg")

cat("You can now look up the diagram in your local folder or in your Demo-geneXplain-platform-account")

Sys.sleep(7)
