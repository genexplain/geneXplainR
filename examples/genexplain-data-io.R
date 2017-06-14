##
## Demonstrating how to import and export data into and from
## the platform.
##
## Please specify server, username and password as well 
## as the output path as commandline arguments.
##
args <- commandArgs(trailingOnly = TRUE)
gx.server <- args[1]
gx.user   <- args[2]
gx.passwd <- args[3]

## The fourth argument should be an empty folder that exists in your
## platform project.

ex.folder <- args[4]

## Loading library and login using specified credentials

library(geneXplainR)
gx.login(gx.server, gx.user, gx.passwd)

## Let us create an example data frame with 4 rows and 2 columns.

dt <- data.frame(Value=rnorm(4),Num=1:4,row.names=c("ELF1","ETV4","ELK1","ETS1"));

## The 'put' command puts a data frame into the platform.

out.table <- paste(ex.folder,"/ets_example_table",sep="")

## The following will write the data frame to a table on the path specified as out.table .
## Please make sure that it is safe to write to the specified path.

gx.put(out.table,dt)

## NOTE:
## - Any item in the specified output folder with the same name as the one
##   specified for the output table (here: ets_example_table) is overwritten
##   by the put operation. Make sure to specify a new path for the output.
##
## - The platform uses only the row.names for the ID column. Therefore the column 
##   that shall be used as ID column within the platform table
##   must be used as row.names in the data frame, otherwise thee designated
##   row names will not be used as row names by the platform.

## To make use of the uploaded table in analyses requiring gene or protein ids,
## one needs to import it using the graphical user interface.

## R can load a table from the platform into a data.frame using the get
## command.

xt <- gx.get(out.table)

## Next we want to import a table into the platform from a file.
## The difference to the upload using 'put' is that the import
## enables using the table in a range of analyses.

## Making the row names an extra column

xt$Genes <- rownames(xt)
write.table(xt,file="example_import_table.txt",sep="\t",quote=F,row.names=F)

## From this listing we see that we want to import the file using the
## "Tabular (*.txt, *.xls, *.tab, etc.)" importer.

gx.importers()

## Let us first gather information about the importer.

gx.import.parameters(ex.folder,"Tabular (*.txt, *.xls, *.tab, etc.)")

## This is the path where the imported table will be located.

imp.path <- paste(ex.folder,"/example_import_table",sep="")

## The following will write the file to imp.path. Please make sure that it is safe to write to 
## the specified path.

## The table will be assigned the type 'Genes' and the gene symbols of ETS factors will appear
## as ids in the platform table.

gx.import("example_import_table.txt",ex.folder,"Tabular (*.txt, *.xls, *.tab, etc.)",
              list(delimiterType="\t",headerRow=1,dataRow=2,
                   tableType="Genes",
                   columnForID="Genes"))

imp.path <- paste(ex.folder,"/example_import_table",sep="")

## As before we can get the table back into a data frame.

xt <- gx.get(imp.path)

## Next we want to export the table.

## This listing provides the available exporters.

gx.exporters()

## With the following we obtain information about the parameters
## for a selected exporter. (Note that the exporter used in this
## example is also the default.)

gx.export.parameters(imp.path,"Tab-separated text (*.txt)");

## The following command will write to the local file named
## 'example_export_table.txt'. Please make sure that it is safe
## to write to the specified path.

gx.export(imp.path,"Tab-separated text (*.txt)",
              list(),
              "example_export_table.txt");

