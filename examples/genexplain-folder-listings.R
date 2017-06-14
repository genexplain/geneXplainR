##
## Demonstrating common locations in the platform workspace and
## how to explore their contents using R
##
## Please specify server, username and password as commandline arguments
##
args <- commandArgs(trailingOnly = TRUE)
gx.server <- args[1]
gx.user   <- args[2]
gx.passwd <- args[3]

## Loading library and login using specified credentials

library(geneXplainR)
gx.login(gx.server, gx.user, gx.passwd)

## Projects

gx.ls("data/Projects")

## Available databases

gx.ls("databases")

## Top folders of the GeneWays database

gx.ls("databases/GeneWays")

## Workflow groups

gx.ls("analyses/Workflows")

## Workflows in group 'Common'

ws.folder <- "analyses/Workflows"
gx.ls(paste(ws.folder,"/",gx.ls(ws.folder)[1],sep=""))

## Top analysis tool folders

gx.ls("analyses")

## Site analysis tools

gx.ls("analyses/Methods/Site analysis")

## Note that there is a dedicated method to list the available
## tools

gx.analysis.list()

## Top Galaxy tool folders

gx.ls("analyses/Galaxy")
