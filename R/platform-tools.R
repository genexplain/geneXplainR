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
    for (i in 1:5) {
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

