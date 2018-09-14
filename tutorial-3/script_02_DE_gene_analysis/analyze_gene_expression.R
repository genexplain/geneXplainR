#
# Drug discovery workflow from multi-omics to compound
# ECCB 2018
# Tutorial 3, Script 02
# Author:  Philip Stegmaier, philip.stegmaier@genexplain.com
# Version: 2018-09-09
#
# Imports complete Limma result table and differentially expressed (DE) gene subsets to the platform.
# Carries out functional enrichment and TFBS analysis to examine biological relevance of the
# determined DE gene sets.
#
library(geneXplainR)
source('../data/access.R')
# Files that are already prepared in the data folder and can optionally be
# generated using script 01.
ifnFile <- "../data/GSE100382_RNAseq_voom_SVA_IFN.txt"
ifnName <- "GSE100382_RNAseq_voom_SVA_IFN"
tnfFile <- "../data/GSE100382_RNAseq_voom_SVA_TNF-IFN.txt"
tnfName <- "GSE100382_RNAseq_voom_SVA_TNF-IFN"
species <- "Human (Homo sapiens)"
#
# Function to extract DE genes, upload data, 
# run Functional classification analysis,
# and search for enriched TF binding sites
#
prepareData <- function(x, dataName, folder) {
    data     <- read.table(x, header=T, sep="\t", row.names=1)
    # We use the log2-fold change and the Bayes factor calculated by Limma 
    # to extract upregulated genes. The Bayes factor > 0 was a bit more stringent than
    # applying an FDR < 0.05 or 0.01 threshold.
    upreg    <- data[data$logFC >= 1 & data$B > 0,]
    # Uploads and imports the table into the platform
    gx.importTable(x, folder, dataName, columnForID = "Gene", tableType = "Genes: Ensembl", species = species)
    upTable  <- paste0(folder,"/",dataName," UP")
    upGenes  <- paste0(upTable," Genes")
    # Uploads data table into platform from an R data.frame
    gx.put(upTable, upreg)
    # Tables added via the put operation need to be converted to a certain type (e.g. Ensembl genes)
    # before some tools can use them.
    gx.analysis("Convert table", list(sourceTable = upTable,
                                      species = species,
                                      sourceType = "Genes: Ensembl",
                                      targetType = "Genes: Ensembl",
                                      outputTable = upGenes,
                                      verbose = F
                                      ))
    # Similar sequence of tasks for unchanged genes
    unchanged <- data[data$adj.P.Val > .5,]
    ucTable   <- paste0(folder,"/",dataName," NC")
    ucGenes   <- paste0(ucTable," Genes")
    gx.put(ucTable, unchanged)
    gx.analysis("Convert table", list(sourceTable = ucTable,
                                      species = species,
                                      sourceType = "Genes: Ensembl",
                                      targetType = "Genes: Ensembl",
                                      outputTable = ucGenes,
                                      verbose = F
                                      ))
    # We conduct some basic examination of the differentially expressed genes
    # using the Functional classification tool which applies the classical method of
    # testing for enrichment of gene sets of known function, e.g. from certain pathways or GO terms,
    # in the differentially expressed genes. The expectation is to observe some
    # gene sets whose relevance for the condition under study can be anticipated or is known.
    gx.analysis("Functional classification", list(sourcePath = upGenes,
                                                  species    = species,
                                                  bioHub     = "Full gene ontology classification",
                                                  minHits    = 1,
                                                  pvalueThreshold = 1,
                                                  outputTable = paste0(upTable," GO"))
    )
    gx.analysis("Functional classification", list(sourcePath = upGenes,
                                                  species    = species,
                                                  bioHub     = "TRANSPATH Pathways (2018.2)",
                                                  minHits    = 1,
                                                  pvalueThreshold = 1,
                                                  outputTable = paste0(upTable," TP 2018.2"))
    )
    # Here we apply the TRANSFAC(R) database to search for motifs that are enriched in upregulated gene promoters
    # compared to five samples of promoters from unchanged genes. The sampling of No sets helps us to determine
    # which motifs are found to be enriched independently of a certain background set.
    gx.analysis("Search for enriched TFBSs (genes)", list(yesSetPath   = upGenes,
                                                          noSetPath    = ucGenes,
                                                          profilePath  = "databases/TRANSFAC(R) 2018.2/Data/profiles/vertebrate_human_p0.001_non3d",
                                                          species      = species,
                                                          from         = -1000,
                                                          to           = 100,
                                                          doSample     = "true",
                                                          sampleNum    = 5,
                                                          sampleSize   = 1500,
                                                          siteFeCutoff = 1.1,
                                                          output       = paste0(upTable," Enriched motifs")
                                                          )
    )
    # Extracts a subset of motifs which were enriched in all samples according to applied criteria and
    # satisfied an average enrichment cutoff.
    gx.analysis("Filter table", list(inputPath = paste0(upTable," Enriched motifs/Enriched motifs Summary"),
                                     filterExpression = '_Accepted > 4 && Avg_adj_site_FE > 1.5',
                                     filteringMode = 'Rows for which expression is true',
                                     outputPath = paste0(upTable," Enriched motifs/Enriched 5x"))
    )
}
# Actual work starts here
gx.login(platformServer, username, password)
gx.createFolder(eccbFolder, "rna-seq")
folder <- paste0(eccbFolder, "/", "rna-seq")
prepareData(ifnFile, ifnName, folder)
prepareData(tnfFile, tnfName, folder)
