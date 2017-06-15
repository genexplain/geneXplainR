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

