#
# Drug discovery workflow from multi-omics to compound
# ECCB 2018
# Tutorial 3, Script 04
# Author:  Philip Stegmaier, philip.stegmaier@genexplain.com
# Version: 2018-09-09
#
# Extracts upregulated TF proteins for enriched motifs from promoter and
# enhancer analysis. Maps expression changes of genes from
# RNA-seq analysis onto the TRANSPATH protein network.
# Carries out upstream regulator search integrating numerical values
# from motif enrichment and DE analysis.
# Eventually, upregulated upstream regulators are compared to
# DE gene sets of the Drug express database.
#
library(geneXplainR)
source('../data/access.R')
gx.login(platformServer, username, password)
folder  <- paste0(eccbFolder,"/upstream_regulators")
gx.createFolder(eccbFolder, "upstream_regulators")
species <- "Human (Homo sapiens)"
targetType <- "Proteins: Transpath peptides"
# Profile to be specified for conversion of TFBSs analysis result tables
siteModels <- "databases/TRANSFAC(R) 2018.2/Data/profiles/vertebrate_human_p0.001_non3d"
# Filters important motifs in active enhancers using site-wise and sequence-wise enrichment
gx.analysis("Filter table", list(
                                 inputPath        = paste0(eccbFolder, "/enhancers/ATAC_T_Peaks_clustered H3K27ac enhancers EM"),
                                 filterExpression = "Adj_site_FE > 1.5 && Adj_seq_FE > 1.5",
                                 outputPath       = paste0(eccbFolder, "/enhancers/ATAC_T_Peaks_clustered H3K27ac enhancers EM 1.5")
                                 ))
# Converts TFs associated with important enhancer motifs to TRANSPATH(R) peptides that are part of the molecular network model
gx.analysis("Matrices to molecules", list(
                                          sitesCollection      = paste0(eccbFolder, "/enhancers/ATAC_T_Peaks_clustered H3K27ac enhancers EM 1.5"),
                                          siteModelsCollection = siteModels,
                                          species              = species,
                                          targetType           = targetType,
                                          outputTable          = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac enhancers EM 1.5 TP peptides")
                                          ))
# Filters important motifs in upregulated promoters using acceptance number in samples and site-wise enrichment
gx.analysis("Filter table", list(
                                 inputPath        = paste0(eccbFolder, "/rna-seq/GSE100382_RNAseq_voom_SVA_TNF-IFN UP Enriched motifs/Enriched motifs Summary"),
                                 filterExpression = "_Accepted > 4 && Avg_adj_site_FE > 1.5",
                                 outputPath       = paste0(eccbFolder, "/rna-seq/GSE100382_RNAseq_voom_SVA_TNF-IFN UP Enriched motifs/Enriched motifs Summary 1.5")
                                 ))
# Converts TFs associated with important promoter motifs to TRANSPATH(R) peptides
gx.analysis("Matrices to molecules", list(
                                          sitesCollection      = paste0(eccbFolder, "/rna-seq/GSE100382_RNAseq_voom_SVA_TNF-IFN UP Enriched motifs/Enriched motifs Summary 1.5"),
                                          siteModelsCollection = siteModels,
                                          species              = species,
                                          targetType           = targetType,
                                          outputTable          = paste0(folder,"/GSE100382_RNAseq_voom_SVA_TNF-IFN UP EM 1.5 TP peptides")
                                          ))
# Creates a common TF set
gx.analysis("Join tables", list(
                                "leftGroup/tablePath"  = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac enhancers EM 1.5 TP peptides"),
                                "rightGroup/tablePath" = paste0(folder,"/GSE100382_RNAseq_voom_SVA_TNF-IFN UP EM 1.5 TP peptides"),
                                mergeColumns           = "true",
                                output                 = paste0(folder,"/TF peptides union")
                                ))
# Downloads joint TF set to a local file
gx.export(paste0(folder,"/TF peptides union"), "Tab-separated text (*.txt)",
          list(includeIds = "true",
               includeHeaders = "true",
               columns = c('Adj. site FE','Adj. seq FE', 'Avg. adj. site FE', 'Avg. adj. seq FE')
               ),
          "TF peptides union.txt")
# Reads TF set into data.frame
dt <- read.table("TF peptides union.txt",header=T,sep="\t")
# Replaces NANs with actual values
dt[which(is.nan(dt$Adj..site.FE)),2:3] <- dt[which(is.nan(dt$Adj..site.FE)),4:5]
colnames(dt) <- c("ID","Site.FE","Seq.FE")
rownames(dt) <- dt$ID
# Copies updated table to platform
gx.put(paste0(folder,"/TF peptides union mg"),dt[,2:3])
# Converts uploaded table to a proper table type
gx.analysis("Convert table", list(sourceTable = paste0(folder,"/TF peptides union mg"),
                                  species = species,
                                  sourceType = targetType,
                                  targetType = targetType,
                                  outputTable = paste0(folder,"/TF peptides union merged"),
                                  verbose = F
                                  ))
# Copied table can be removed
gx.delete(folder, "TF peptides union mg")
# Maps upregulated genes measured by RNA-seq to TRANSPATH(R) proteins
gx.analysis("Convert table", list(sourceTable = paste0(eccbFolder, "/rna-seq/GSE100382_RNAseq_voom_SVA_TNF-IFN UP Genes"),
                                  species = species,
                                  sourceType = "Genes: Ensembl",
                                  targetType = "Proteins: Transpath",
                                  outputTable = paste0(folder,"/GSE100382_RNAseq_voom_SVA_TNF-IFN UP proteins"),
                                  verbose = F
                                  ))
# Maps all genes measured by RNA-seq to TRANSPATH(R) proteins
gx.analysis("Convert table", list(sourceTable = paste0(eccbFolder, "/rna-seq/GSE100382_RNAseq_voom_SVA_TNF-IFN"),
                                  species = species,
                                  sourceType = "Genes: Ensembl",
                                  targetType = "Proteins: Transpath",
                                  outputTable = paste0(folder,"/GSE100382_RNAseq_voom_SVA_TNF-IFN proteins"),
                                  verbose = F
                                  ))
# Obtains upregulated TFs with enriched motifs
gx.analysis("Intersect tables", list(
                                     "leftGroup/tablePath"  = paste0(folder,"/TF peptides union merged"),
                                     "rightGroup/tablePath" = paste0(folder,"/GSE100382_RNAseq_voom_SVA_TNF-IFN UP proteins"),
                                     mergeColumns           = "true",
                                     output                 = paste0(folder,"/TF peptides union merged UP")
                                     ))
# Regulator search taking into account site-wise enrichment as an indicator of TF importance,
# log-FC to weight paths through signal transduction network
gx.searchRegulators(
                    sourcePath   = paste0(folder,"/TF peptides union merged UP"),
                    weightColumn = "Site.FE",
                    maxRadius    = 6,
                    bioHub       = "Transpath (Species specific) (2018.2)",
                    contextDecorators = list("A" = list(table  = paste0(folder,"/GSE100382_RNAseq_voom_SVA_TNF-IFN proteins"),
                                                        column = "logFC",
                                                        decay  = 0.1)),
                    outputTable = paste0(folder,"/TF peptides union merged UP Upstream 6")
                    )
# Maps identified regulators to Ensembl genes
gx.analysis("Convert table", list(sourceTable = paste0(folder,"/TF peptides union merged UP Upstream 6"),
                                  species = species,
                                  sourceType = "Proteins: Transpath",
                                  targetType = "Genes: Ensembl",
                                  outputTable = paste0(folder,"/TF peptides union merged UP Upstream 6 Genes"),
                                  verbose = F
                                  ))
# Obtains upregulated master regulators
gx.analysis("Intersect tables", list(
                                     "leftGroup/tablePath"  = paste0(folder,"/TF peptides union merged UP Upstream 6 Genes"),
                                     "rightGroup/tablePath" = paste0(eccbFolder, "/rna-seq/GSE100382_RNAseq_voom_SVA_TNF-IFN UP Genes"),
                                     mergeColumns           = "true",
                                     output                 = paste0(folder,"/TF peptides union merged Upstream 6 Genes UP")
                                     ))
# Applies Functional classification to correlate master regulator set with gene sets affected by drug compounds
# according to Drug Express
gx.analysis("Functional classification", list(sourcePath = paste0(folder,"/TF peptides union merged UP Upstream 6 Genes"),
                                              species    = species,
                                              bioHub     = "Repository folder",
                                              repositoryHubRoot = "databases/DrugExpress/Data/tables",
                                              minHits    = 1,
                                              pvalueThreshold = 1,
                                              outputTable = paste0(folder,"/TF peptides union merged UP Upstream 6 Drugs")
                                              ))
