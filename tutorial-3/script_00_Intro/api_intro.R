#
# Drug discovery workflow from multi-omics to compound
# ECCB 2018
# Tutorial 3, Script 00
# Author:  Philip Stegmaier, philip.stegmaier@genexplain.com
# Version: 2018-09-09
#
# This is an introductory script to show a few commands of the
# geneXplainR API.
#
library(geneXplainR)
source('../data/access.R')
#
# First step to use the platform webservice
#
gx.login(platformServer, username, password)
#
# View the contents of some folders
# There are three base folders that are usually of interest:
# 1) databases
# 2) data
# 3) analyses
# The base folders can be found as tabs in the GUI with
# corresponding names.
#
gx.ls('data/Projects')
gx.ls('analyses')
gx.ls('databases')
#
# View methods for data handling
#
gx.ls('analyses/Methods/Data manipulation')
#
# Get description of parameters to "Convert table"
#
gx.analysis.parameters('Convert table')
#
# Create a folder for subsequent analyses
#
parts  <- strsplit(eccbFolder,'/')[[1]]
folder <- paste(parts[1:(length(parts)-1)], collapse='/', sep='')
name   <- tail(parts, n=1)
gx.createFolder(folder, name)
#
# You are also welcome to take a look at the examples branch of geneXplainR:
# https://github.com/genexplain/geneXplainR/tree/examples
