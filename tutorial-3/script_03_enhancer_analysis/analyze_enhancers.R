#
# Drug discovery workflow from multi-omics to compound
# ECCB 2018
# Tutorial 3, Script 03
# Author:  Philip Stegmaier, philip.stegmaier@genexplain.com
# Version: 2018-09-09
#
# Imports ATAC-seq and H3K27ac peak regions and lifts them to hg38, intersects them
# and removes those regions located in promoters in order to determine open chromatin
# enhancers for subsequent TFBS analysis. This process follows the description of the
# original study where enhancers were located by the same principle.
# TFBS analysis uses the 'Search for enriched TFBSs' algorithm. An example is also
# provided with the MEALR algorithm and the HOCOMOCO databases.
# 
#
library(geneXplainR)
source('../data/access.R')
gx.login(platformServer, username, password)
folder  <- paste0(eccbFolder,"/enhancers")
gx.createFolder(eccbFolder, "enhancers")
# The genome to which NGS reads had been mapped to by authors
# is specified during BED file upload
genomeDb = "Ensembl 72.37 Human (hg19)"
# Short genome identifier
genomeId = "hg19"
# String specififying lift-over mapping to be applied
mapping <- "hg19->hg38"
# Creates a "track" of genomic intervals for genes
# recognized in RNA-seq processing.
# Uses a slightly extended promoter window from -2000 to 1000.
sapply(c("GSE100382_RNAseq_voom_SVA_IFN",
         "GSE100382_RNAseq_voom_SVA_TNF-IFN"),
       function(x) {
           gx.analysis("Gene set to track",
                       list(sourcePath = paste0(eccbFolder,"/rna-seq/",x),
                            species    = "Human (Homo sapiens)",
                            from       = -2000,
                            to         = 1000,
                            destPath   = paste0(folder,"/",x," promoters"))
                       )
       })
# Imports local BED file into platform and lifts coordinates to hg38
sapply(c("ATAC_IFN_N_Peaks_clustered.bed",
         "ATAC_T_Peaks_clustered.bed",
         "GSE100381_H3K27ac_T_Peaks.bed"),
       function(x) {
           name <- strsplit(basename(x),"\\.")[[1]][1]
           destPath <- paste0(folder,"/",name)
           gx.importBedFile(x, destPath, genomeDb, genomeId)
           params <- list(input = destPath, 
                          mapping = mapping,
                          out_file1= paste0(destPath,".mapped"), 
                          out_file2= paste0(destPath,".unmapped"))
           gx.analysis("liftOver1", params)
       }
       )
# Intersects open chromatin regions and H3K27ac marks to obtain
# putative enhancers
# For ATAC-seq identified regions after IFNa treatment
gx.analysis("Intersect tracks", 
            list(
                 inputTrackPath  = paste0(folder,"/ATAC_IFN_N_Peaks_clustered.mapped"),
                 filterTrackPath = paste0(folder,"/GSE100381_H3K27ac_T_Peaks.mapped"),
                 operation       = "Intersection",
                 overlapProp     = 0.5,
                 maxUncovered    = 100000,
                 outputTrackPath = paste0(folder,"/ATAC_IFN_N_Peaks_clustered H3K27ac")
                 )
            )
# As above, for ATAC-seq identified regions after TNF treatment
gx.analysis("Intersect tracks", 
            list(
                 inputTrackPath  = paste0(folder,"/ATAC_T_Peaks_clustered.mapped"),
                 filterTrackPath = paste0(folder,"/GSE100381_H3K27ac_T_Peaks.mapped"),
                 operation       = "Intersection",
                 overlapProp     = 0.5,
                 maxUncovered    = 100000,
                 outputTrackPath = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac")
                 )
            )
# Removes putative IFNa-related enhancers that overlap with promoters
gx.analysis("Intersect tracks", 
            list(
                 inputTrackPath  = paste0(folder,"/ATAC_IFN_N_Peaks_clustered H3K27ac"),
                 filterTrackPath = paste0(folder,"/GSE100382_RNAseq_voom_SVA_IFN promoters"),
                 operation       = "Difference",
                 overlapProp     = 0.01,
                 maxUncovered    = 100000,
                 outputTrackPath = paste0(folder,"/ATAC_IFN_N_Peaks_clustered H3K27ac enhancers")
                 )
            )
# Removes putative TNF-related enhancers that overlap with promoters
gx.analysis("Intersect tracks", 
            list(
                 inputTrackPath  = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac"),
                 filterTrackPath = paste0(folder,"/GSE100382_RNAseq_voom_SVA_TNF-IFN promoters"),
                 operation       = "Difference",
                 overlapProp     = 0.01,
                 maxUncovered    = 100000,
                 outputTrackPath = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac enhancers")
                 )
            )
# Creates random interval tracks not overlapping with enhancers for subsequent
# TFBS analysis
sapply(c(paste0(folder,"/ATAC_IFN_N_Peaks_clustered.mapped"),
         paste0(folder,"/ATAC_T_Peaks_clustered.mapped")),
       function(x) {
           gx.analysis("Create random track",
                       list(
                            inputTrackPath = x,
                            dbSelector = "",
                            species = "Human (Homo sapiens)",
                            standardChromosomes = "true",
                            seqNumber = 1500,
                            withOverlap = "false",
                            outputTrackPath = paste0(x," random"))
                       )
       }
       )
# The following three commands analyze TFBSs in active IFNa- or TNF-related enhancers, using
# the TRANSFAC(R) database or, for the MEALR algorithm, the motifs of the HOCOMOCO database.
gx.analysis("Search for enriched TFBSs (tracks)", list(yesSetPath   = paste0(folder,"/ATAC_IFN_N_Peaks_clustered H3K27ac enhancers"),
                                                       noSetPath    = paste0(folder,"/ATAC_IFN_N_Peaks_clustered.mapped random"),
                                                       profilePath  = "databases/TRANSFAC(R) 2018.2/Data/profiles/vertebrate_human_p0.001_non3d",
                                                       dbSelector   = "Ensembl 91.38 Human (hg38)",
                                                       output       = paste0(folder,"/ATAC_IFN_N_Peaks_clustered H3K27ac enhancers EM")
                                                       )
)
gx.analysis("Search for enriched TFBSs (tracks)", list(yesSetPath   = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac enhancers"),
                                                       noSetPath    = paste0(folder,"/ATAC_T_Peaks_clustered.mapped random"),
                                                       profilePath  = "databases/TRANSFAC(R) 2018.2/Data/profiles/vertebrate_human_p0.001_non3d",
                                                       dbSelector   = "Ensembl 91.38 Human (hg38)",
                                                       output       = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac enhancers EM")
                                                       )
)
# Uncomment to run MEALR as well. The output is not required in subsequent analysis steps. Be aware that it takes a long time to complete.
#gx.analysis("MEALR (tracks)", list(yesSetPath   = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac enhancers"),
#                                   noSetPath    = paste0(folder,"/ATAC_T_Peaks_clustered.mapped random"),
#                                   profilePath  = "databases/HOCOMOCO v10/Data/PWM_HUMAN_mono_pval=0.001",
#                                   dbSelector   = "Ensembl 91.38 Human (hg38)",
#                                   output       = paste0(folder,"/ATAC_T_Peaks_clustered H3K27ac enhancers MEALR")
#                                   )
#)

