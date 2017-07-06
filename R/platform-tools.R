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
#' @param inputTrack   path to track with input ChIP-seq intervals
#' @param species      species of the input track genome
#' @param resultFolder path of result folder
#' @param wait         set true to wait for the analysis to complete
#' @param verbose      set true for more progress info
#' @keywords workflow, ChIP-seq, classification, target gene
#' @export
gx.classifyChipSeqTargets <- function(inputTrack,species="Human (Homo sapiens)",resultFolder,wait=T,verbose=F) {
    gx.workflow("analyses/Workflows/Common/ChIP-Seq - Identify and classify target genes",
                list("Input track"    = inputTrack,
                     "Species"        = species,
                     "Results folder" = resultFolder),
                wait,
                verbose)
}
