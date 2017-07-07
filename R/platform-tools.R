#############################################################
# Copyright (c) 2017 geneXplain GmbH, Wolfenbuettel, Germany
#
# Author: Philip Stegmaier
#
# Please see license that accompanies this software.
#############################################################


#' Create a Venn diagram for up to three tables.
#' 
#' @param table1Path  path to first (left) table
#' @param table2Path  path to second (right) table
#' @param table3Path  path to third (middle) table (optional)
#' @param table1Name  name/title of left table
#' @param table2Name  name/title of right table
#' @param table3Name  name/title of middle table
#' @param output      output path (does not need to exist)
#' @param simple      set true for circle diameters proportional to group size
#' @param wait        set true to wait for the analysis to complete
#' @param verbose     set true for more progress info
#' @keywords Venn, diagram
#' @export
gx.vennDiagrams <- function(table1Path,table2Path,table3Path="",table1Name="Left",table2Name="Right",table3Name="Middle",output,simple=T,wait=T,verbose=F) {
    gx.analysis("Venn diagrams",list(table1Path=table1Path,
                    table2Path=table2Path,
                    table3Path=table3Path,
                    table1Name=table1Name,
                    table2Name=table2Name,
                    table3Name=table3Name,
                    output=output,
                    simple=simple),wait,verbose)
}

#' Runs the workflow \emph{ChIP-Seq - Identify and classify target genes}
#'
#' @param inputTrack    path to track with input ChIP-seq intervals
#' @param species       species of the input track genome
#' @param resultFolder  path of result folder
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, ChIP-seq, classification, target gene
#' @export
gx.classifyChipSeqTargets <- function(inputTrack,species="Human (Homo sapiens)",resultFolder,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/Common/ChIP-Seq - Identify and classify target genes",
                list("Input track"    = inputTrack,
                     "Species"        = species,
                     "Skip completed" = skipCompleted,
                     "Results folder" = resultFolder),
                wait,
                verbose)
}

#' Runs the workflow \emph{Mapping to ontologies (Gene table)}
#'
#' @param inputTable    input table with gene ids
#' @param species       species of the input track genome
#' @param resultFolder  path of result folder
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, classification, ontology, gene, function
#' @export
gx.mapGenesToOntologies <- function(inputTable,species="Human (Homo sapiens)",resultFolder,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/Common/Mapping to ontologies (Gene table)",
                list("Input table"    = inputTable,
                     "Species"        = species,
                     "Skip completed" = skipCompleted,
                     "Results folder" = resultFolder),
                wait,
                verbose)
}

#' Runs the workflow \emph{Explain my genes}
#'
#' @param inputTable    input table with gene ids
#' @param species       species of the input track genome
#' @param resultFolder  path of result folder
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, upstream analysis
#' @export
gx.explainMyGenes <- function(inputTable,species="Human (Homo sapiens)",resultFolder,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/Common/Explain my genes",
                list("Input gene set" = inputTable,
                     "Species"        = species,
                     "Skip completed" = skipCompleted,
                     "Results folder" = resultFolder),
                wait,
                verbose)
}

#' Runs the workflow \emph{Compute differentially expressed genes using Limma}
#'
#' @param inputTable    input table with expression data
#' @param probeType     type of probes
#' @param species       species of the input track genome
#' @param conditions    a list with condition names and columns
#' @param resultFolder  path of result folder
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, differential expression, limma
#' @export
gx.limmaWorkflow <- function(inputTable,probeType="Probes: Affymetrix",species="Human (Homo sapiens)",conditions=list(),resultFolder,skipCompleted=T,wait=T,verbose=F) {
    stopifnot(length(conditions) > 1)
    params <- list("Input table"    = inputTable,
                   "Probe type"     = probeType,
                   "Species"        = species,
                   "Skip completed" = skipCompleted,
                   "Results folder" = resultFolder)
    for (i in 1:5) {
        cnd <- paste0("Condition_",i)
        cls <- paste0(i,"_Columns")
        if (length(conditions[[cls]]) > 0) {
            params[[cls]] <- conditions[[cls]]
            if (length(conditions[[cnd]]) > 0) {
                params[[cnd]] <- conditions[[cnd]]
            }
        }
    }
    gx.workflow("analyses/Workflows/Common/Compute differentially expressed genes using Limma",
                params,
                wait,
                verbose)
}

#' Runs the workflow \emph{Compute differentially expressed genes using EBarrays}
#'
#' @param inputTable     input table with expression data
#' @param probeType      type of probes
#' @param species        species of the input track genome
#' @param controlName    name for the control column group
#' @param controlColumns list of control column names
#' @param conditions     a list with condition names and columns
#' @param resultFolder   path of result folder
#' @param skipCompleted  skip already completed steps
#' @param wait           set true to wait for the analysis to complete
#' @param verbose        set true for more progress info
#' @keywords workflow, differential expression, EBarrays
#' @export
gx.ebarraysWorkflow <- function(inputTable,probeType="Probes: Affymetrix",species="Human (Homo sapiens)",controlName="Control",controlColumns=c(),conditions=list(),resultFolder,skipCompleted=T,wait=T,verbose=F) {
    stopifnot(length(conditions) > 1)
    stopifnot(length(controlColumns) > 0)
    params <- list("Input table"     = inputTable,
                   "Probe type"      = probeType,
                   "Species"         = species,
                   "Control group"   = controlName,
                   "Control_columns" = controlColumns,
                   "Skip completed"  = skipCompleted,
                   "Results folder"  = resultFolder)
    for (i in 2:5) {
        cnd <- paste0("group_",i)
        cls <- paste0("Columns_",cnd)
        if (length(conditions[[cls]]) > 0) {
            params[[cls]] <- conditions[[cls]]
            if (length(conditions[[cnd]]) > 0) {
                params[[cnd]] <- conditions[[cnd]]
            }
        }
    }
    gx.workflow("analyses/Workflows/Common/Compute differentially expressed genes using EBarrays",
                params,
                wait,
                verbose)
}


#' Runs the workflow \emph{Identify enriched motifs in promoters (TRANSFAC(R))}
#'
#' @param inputYesSet   yes/positive/foreground gene set
#' @param inputNoSet    no/negative/background gene set
#' @param profile       matrix profile
#' @param species       species of the input track genome
#' @param foldEnriched  filter by fold enrichment
#' @param promoterStart first base of a promoter relative to TSS
#' @param promoterEnd   last base of a promoter relative to TSS
#' @param allowBigInput set true to allow for large data sets
#' @param resultFolder  path of result folder
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, 
#' @export
gx.enrichedTFBSGenes <- function(inputYesSet,inputNoSet,profile,species="Human (Homo sapiens)",foldEnriched=1.0,promoterStart=-1000,promoterEnd=100,allowBigInput=F,resultFolder,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/TRANSFAC/Identify enriched motifs in promoters (TRANSFAC(R))",
                list("Input Yes gene set"             = inputYesSet,
                     "Input No gene set"              = inputNoSet,
                     "Profile"                        = profile,
                     "Species"                        = species,
                     "Filter by TFBS enrichment fold" = foldEnriched,
                     "Start promoter"                 = promoterStart,
                     "End promoter"                   = promoterEnd,
                     "Allow big input"                = allowBigInput,
                     "Result folder"                  = resultFolder,
                     "Skip completed"                 = skipCompleted,
                     "Results folder"                 = resultFolder),
                wait,
                verbose)
}

#' Runs the workflow \emph{Upstream analysis (TRANSFAC(R) and GeneWays)}
#'
#' @param inputYesSet   yes/positive/foreground gene set
#' @param inputNoSet    no/negative/background gene set
#' @param species       species of the input track genome
#' @param profile       matrix profile
#' @param promoterStart first base of a promoter relative to TSS
#' @param promoterEnd   last base of a promoter relative to TSS
#' @param resultFolder  path of result folder
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, upstream analysis, TRANSFAC, GeneWays
#' @export
gx.upstreamAnalysisTransfacGeneWays <- function(inputYesSet,inputNoSet,profile,species="Human (Homo sapiens)",promoterStart=-1000,promoterEnd=100,resultFolder,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/TRANSFAC/Upstream analysis (TRANSFAC(R) and GeneWays)",
                list("Input Yes gene set"             = inputYesSet,
                     "Input No gene set"              = inputNoSet,
                     "Profile"                        = profile,
                     "Species"                        = species,
                     "Start of promoter"              = promoterStart,
                     "End of promoter"                = promoterEnd,
                     "Results folder"                 = resultFolder,
                     "Skip completed"                 = skipCompleted,
                     "Results folder"                 = resultFolder),
                wait,
                verbose)
}

#' Runs the workflow \emph{Upstream analysis (TRANSFAC(R) and TRANSPATH(R))}
#'
#' @param inputYesSet   yes/positive/foreground gene set
#' @param inputNoSet    no/negative/background gene set
#' @param species       species of the input track genome
#' @param profile       matrix profile
#' @param promoterStart first base of a promoter relative to TSS
#' @param promoterEnd   last base of a promoter relative to TSS
#' @param resultFolder  path of result folder
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, upstream analysis, TRANSFAC, TRANSPATH
#' @export
gx.upstreamAnalysisTransfacTranspath <- function(inputYesSet,inputNoSet,profile,species="Human (Homo sapiens)",promoterStart=-1000,promoterEnd=100,resultFolder,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/TRANSPATH/Upstream analysis (TRANSFAC(R) and TRANSPATH(R))",
                list("Input Yes gene set"             = inputYesSet,
                     "Input No gene set"              = inputNoSet,
                     "Profile"                        = profile,
                     "Species"                        = species,
                     "Start of promoter"              = promoterStart,
                     "End of promoter"                = promoterEnd,
                     "Results folder"                 = resultFolder,
                     "Skip completed"                 = skipCompleted,
                     "Results folder"                 = resultFolder),
                wait,
                verbose)
}

#' Runs the workflow \emph{Focused upstream analysis (TRANSFAC(R) and TRANSPATH(R))}
#'
#' @param inputYesSet   yes/positive/foreground gene set
#' @param inputNoSet    no/negative/background gene set
#' @param species       species of the input track genome
#' @param profile       matrix profile
#' @param foldEnriched  filter by fold enrichment
#' @param promoterStart first base of a promoter relative to TSS
#' @param promoterEnd   last base of a promoter relative to TSS
#' @param resultFolder  path of result folder
#' @param allowBigInput set true to allow for large data sets
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, upstream analysis, TRANSFAC, GeneWays
#' @export
gx.focusedUpstreamAnalysis <- function(inputYesSet,inputNoSet,species="Human (Homo sapiens)",profile,foldEnriched=1.0,promoterStart=-1000,promoterEnd=100,resultFolder,allowBigInput=F,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/TRANSPATH/Focused upstream analysis (TRANSFAC(R) and TRANSPATH(R))",
                list("Input Yes gene set"             = inputYesSet,
                     "Input No gene set"              = inputNoSet,
                     "Profile"                        = profile,
                     "Filter by TFBS enrichment fold" = foldEnriched,
                     "Species"                        = species,
                     "Start of promoter"              = promoterStart,
                     "End of promoter"                = promoterEnd,
                     "Results folder"                 = resultFolder,
                     "Allow big input"                = allowBigInput,
                     "Skip completed"                 = skipCompleted,
                     "Results folder"                 = resultFolder),
                wait,
                verbose)
}

#' Runs the workflow \emph{Enriched upstream analysis (TRANSFAC(R) and TRANSPATH(R))}
#'
#' @param inputYesSet   yes/positive/foreground gene set
#' @param inputNoSet    no/negative/background gene set
#' @param species       species of the input track genome
#' @param profile       matrix profile
#' @param foldEnriched  filter by fold enrichment
#' @param promoterStart first base of a promoter relative to TSS
#' @param promoterEnd   last base of a promoter relative to TSS
#' @param resultFolder  path of result folder
#' @param allowBigInput set true to allow for large data sets
#' @param skipCompleted skip already completed steps
#' @param wait          set true to wait for the analysis to complete
#' @param verbose       set true for more progress info
#' @keywords workflow, upstream analysis, TRANSFAC, GeneWays
#' @export
gx.enrichedUpstreamAnalysis <- function(inputYesSet,inputNoSet,species="Human (Homo sapiens)",profile,foldEnriched=1.0,promoterStart=-1000,promoterEnd=100,resultFolder,allowBigInput=F,skipCompleted=T,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/TRANSPATH/Enriched upstream analysis (TRANSFAC(R) and TRANSPATH(R))",
                list("Input Yes gene set"             = inputYesSet,
                     "Input No gene set"              = inputNoSet,
                     "Profile"                        = profile,
                     "Filter by TFBS enrichment fold" = foldEnriched,
                     "Species"                        = species,
                     "Start of promoter"              = promoterStart,
                     "End of promoter"                = promoterEnd,
                     "Results folder"                 = resultFolder,
                     "Allow big input"                = allowBigInput,
                     "Skip completed"                 = skipCompleted,
                     "Results folder"                 = resultFolder),
                wait,
                verbose)
}

