#############################################################
# Copyright (c) 2017 geneXplain GmbH, Wolfenbuettel, Germany
#
# Author: Philip Stegmaier
#
# Please see license that accompanies this software.
#############################################################

#' @import utils
#' @import RCurl


gx.getInternals <- function() {
    .internals <- c("biouml.query", "queryJSON", "next.job.id", "biouml.parameters")
    gx.imp <- structure(mapply(function(.internals,i) getFromNamespace(i,"rbiouml"),.internals,.internals),class=c("internal"))
    gx.imp
}

connectionAttempts = 3

#' Regulator search
#'
#' Searches for signal transduction regulators of input proteins
#'
#' @param sourcePath          Path of table with input protein/molecule set
#' @param weightColumn        Name of column in input table with weights (optional)
#' @param limitInputSize      True to take only the first N inputs
#' @param inputSizeLimit      Number of inputs to use from input table
#' @param maxRadius           Max. number of reactions/interactions to connect inputs to regulators
#' @param scoreCutoff         Cutoff for regulator score
#' @param bioHub              Molecular network database to use
#' @param species             Species whose network shall be analyzed
#' @param calculateFdr        True to create random inputs for Z-score calculation
#' @param fdrCutoff           Cutoff to consider regulators significant
#' @param zscoreCutoff        Cutoff for Z-score
#' @param penalty             Penalty for non-input hits in regulator network
#' @param isoformFactor       Normalize multi-forms
#' @param contextDecorators   List of lists with context decorator parameters like list('A'=list(table='table path', column='column name', 'decay'=<value>), list(), ...)
#' @param removeNodeDecorators List of table paths specifying nodes to remove
#' @param outputTable         Path to store analysis results
#' @param wait                True to wait for job to complete
#' @param verbose             True for more progress info
#' @return  a string containing the status of the request in JSON format
#' @export
gx.searchRegulators <- function(sourcePath, weightColumn, limitInputSize = FALSE, inputSizeLimit = 1000, maxRadius = 5, scoreCutoff = 0.2, bioHub, species = "Human (Homo sapiens)", calculateFdr = TRUE, fdrCutoff = 0.05, zscoreCutoff = 1.0, penalty = 0.1, isoformFactor = TRUE,  contextDecorators = c(), removeNodeDecorators = c(), outputTable, wait = TRUE, verbose = TRUE) {
	gx.getConnection()
    gx.imp <- gx.getInternals()
	jobID  <- gx.imp$next.job.id();
	lis = "false"
	if (limitInputSize) {
		lis = "true"
	}
	fdr = "true"
	if (!calculateFdr) {
		fdr = "false"
	}
	iso = "true"
	if (!isoformFactor) {
		iso = "false"
	}
	decorators <- c()
	for (cd in contextDecorators) {
		decorators <- c(decorators, paste0("[{\"name\":\"decoratorName\",\"value\":\"Apply Context\"},",
									"{\"name\":\"parameters\", \"value\":[",
									"{\"name\":\"tableName\", \"value\": \"",cd$table,"\"},",
									"{\"name\":\"tableColumn\", \"value\": \"",cd$column,"\"},",
									"{\"name\":\"decayFactor\", \"value\": ",cd$decay,"}",
									"]}]"))
	}
	for (rn in removeNodeDecorators) {
		decorators <- c(decorators, paste0("[{\"name\":\"decoratorName\",\"value\":\"Remove nodes\"},",
									"{\"name\":\"parameters\", \"value\":[",
									"{\"name\":\"inputTable\", \"value\": \"",rn,"\"}",
									"]}]"))
	}
	json   <- paste0("[",
						"{\"name\":\"sourcePath\", \"value\": \"",sourcePath,"\"},",
						"{\"name\":\"weightColumn\", \"value\": \"",weightColumn,"\"},",
						"{\"name\":\"isInputSizeLimited\", \"value\": ",lis,"},",
						"{\"name\":\"inputSizeLimit\", \"value\": ",inputSizeLimit,"},",
						"{\"name\":\"maxRadius\", \"value\": ",maxRadius,"},",
						"{\"name\":\"scoreCutoff\", \"value\": ",scoreCutoff,"},",
						"{\"name\":\"bioHub\", \"value\": \"",bioHub,"\"},",
						"{\"name\":\"species\", \"value\": \"",species,"\"},",
						"{\"name\":\"calculatingFDR\", \"value\": ",fdr,"},",
						"{\"name\":\"FDRcutoff\", \"value\": ",fdrCutoff,"},",
						"{\"name\":\"ZScoreCutoff\", \"value\": ",zscoreCutoff,"},",
						"{\"name\":\"penalty\", \"value\": ",penalty,"},",
						"{\"name\":\"decorators\", \"value\": [",paste(decorators, sep='', collapse=','),"]},",
						"{\"name\":\"isoformFactor\", \"value\": ",isoformFactor,"},",
						"{\"name\":\"outputTable\", \"value\": \"",outputTable,"\"}",
					 "]"
	)
	params <- list(de    = "analyses/Methods/Molecular networks/Regulator search",
				   jobID = jobID,
				   json  = json,
				   showMode = 1
			  )
	resp <- gx.imp$biouml.query("/web/analysis", params=params)
	if (wait) gx.job.wait(jobID, verbose)
	resp
}

#' Import a BED file
#'
#' Imports a BED file to specified data item
#'
#' @param bedFile  BED file to import
#' @param destPath Platform path of resulting track item
#' @param genomeDb Genome database
#' @param genomeId Genome id string, e.g. mm10, hg38
#' @param wait        True to wait for job to complete
#' @param verbose     True for more progress info
#' @return a string containing the status of the request in JSON format
#' @export
gx.importBedFile <- function(bedFile, destPath, genomeDb = "Ensembl 91.38 Human (hg38)", genomeId = "hg38", wait=T, verbose=T) {
	gx.getConnection()
    gx.imp <- gx.getInternals()
	fileID <- gx.imp$next.job.id();
    jobID <- gx.imp$next.job.id();
    params <- list(fileID=fileID, file=fileUpload(bedFile))
    gx.imp$biouml.query("/web/upload", params=params)
	json <- paste0("[\n {\"name\": \"file\",\n\"value\": \"",fileID,"\"},\n",
				   "{\"name\": \"resultPath\",\n\"value\": \"",destPath,"\"},",
				   "{\"name\": \"properties\",\n \"value\":[{\"name\":\"dbSelector\",\"value\":\"",genomeDb,"\"},",
				   "{\"name\":\"genomeId\",\"value\":\"",genomeId,"\"}]}]")
	params <- list(de = "analyses/Methods/Import/BED format (*.bed)",
				   jobID    = jobID,
				   json     = json,
				   showMode = 0
			  )
	resp <- gx.imp$biouml.query("/web/analysis", params=params)
	if (wait) gx.job.wait(jobID, verbose)
	resp
}

#' Track to gene set
#'
#' Maps one or more tracks to genes of the most recent Ensembl release
#'
#' @param tracks      List of track paths
#' @param species     Name of the species
#' @param from        Gene region start relative to 5' end of Ensembl gene
#' @param to          Gene region end relative to 3' end of Ensembl gene
#' @param resultTypes List of statistics to report (Schematic, + or -, Count, Count in exons, Count in introns, Count in 5', Count in 3', Structure, Positions)
#' @param allGenes    True if all genes shall be reported regardless of hit
#' @param destPath    output path
#' @param wait        True to wait for job to complete
#' @param verbose     True for more progress info
#' @return a string containing the status of the request in JSON format
#' @export
gx.trackToGeneSet <- function(tracks, species, from, to, resultTypes=c("Count"), allGenes=F, destPath, wait=T, verbose=T) {
	gx.imp <- gx.getInternals()
	jobID  <- gx.imp$next.job.id()
	ag = "false"
	if (allGenes) {
		ag = "true"
	}
	json = paste0("[{\"name\":\"sourcePaths\",\"value\":[\"",paste(tracks,collapse='","'),"\"]}",
				  ",{\"name\":\"species\",\"value\":\"",species,"\"}",
			      ",{\"name\":\"from\",\"value\":\"",from,"\"}",
			      ",{\"name\":\"to\",\"value\":\"",to,"\"}",
			      ",{\"name\":\"resultTypes\",\"value\":[\"",paste(resultTypes,collapse='","'),"\"]}",
				  ",{\"name\":\"allGenes\",\"value\":",ag,"},{\"name\":\"destPath\",\"value\":\"",destPath,"\"}]")
	params <- list(de    = "analyses/Methods/Data+manipulation/Track to gene set",
				   jobID = jobID,
				   showMode = 1,
				   json = json)
	resp   <- gx.imp$biouml.query("/web/analysis", params=params)
	if (wait) gx.job.wait(jobID, verbose)
	resp
}


#' Create a new project
#'
#' This function creates a new project within the platform workspace.
#' A project is a prerequisite to be able to upload data, perform analyses or
#' to run workflows.
#'
#' @param name name of the project
#' @param description a short description of the project
#' @return a string containing the status of the request in JSON format
#' @export
gx.createProject <- function(name, description="New platform project") {
    con <- gx.getConnection()
    gx.imp <- gx.getInternals()
    gx.imp$biouml.query("/support/createProjectWithPermission", params=list(user=con$user, pass=con$pass, project=name, description=description)) 
}

#' Create a folder
#'
#' This function creates a new folder within an existing parent folder.
#'
#' @param path        parent folder in which the new folder is created
#' @param folderName  name of the new folder 
#' @return a string containing the status of the request in JSON format
#' @export 
gx.createFolder <- function(path, folderName) {
    gx.getConnection()
    params <- list("service" = "access.service",
            "command" = "25",
            "dc" = path,
            "de" =  folderName)
    gx.imp <- gx.getInternals()
    gx.imp$queryJSON("/web/data", params)
}

#' Delete a workspace item
#'
#' This function deletes an item within the workspace. The item may be
#' a folder or another type of element. 
#' Handle with care, because deletion may be irreversible.
#'
#' @param folder folder that contains the item
#' @param name   name of the item
#' @return type and value of the response. A type of 0 indicates success.
#' @export
gx.delete <- function(folder, name) {
    gx.getConnection()
    params <- list("service" = "access.service",
                   "command" = "26",
                   "dc" = folder,
                   "de" =  name)
    gx.imp <- gx.getInternals()
    gx.imp$queryJSON("/web/data", params)
}



#' Import a table from a text file
#'
#' This function imports a table into an existing platform folder.
#'
#' @param tableFile       path to file with the table
#' @param platformFolder  folder into which the table is imported
#' @param tableName       name for the table within the platform
#' @param delim           column delimiter, one of the strings (Tab, Spaces, Commas, Pipes)
#' @param processQuotes   true to process quotation marks
#' @param headerRow       row index of the table header
#' @param dataRow         row index of the first data row
#' @param commentString   string to recognize comment lines
#' @param columnForID     name of column with ids
#' @param addSuffix       true to add suffix to ensure unique ids
#' @param tableType       type of platform table, e.g. Genes: Ensembl
#' @param species         Latin name of species
#' @return a string containing the status of the request in JSON format
#' @export 
gx.importTable <- function(tableFile, platformFolder, tableName = "imported_table", processQuotes = TRUE, 
						   delim = 'Tab', headerRow = 1, dataRow = 2, commentString = "", columnForID = "",
						   addSuffix = FALSE, tableType = "", species = "Unspecified") {
    gx.getConnection()
    gx.imp <- gx.getInternals()
	fileID <- gx.imp$next.job.id();
    jobID <- gx.imp$next.job.id();
    params <- list(fileID=fileID, file=fileUpload(tableFile))
    gx.imp$biouml.query("/web/upload", params=params)
	if (length(tableName) == 0) {
		tableName = basename(tableFile)
	}
	delimiterType = 0
	if (delim == "Spaces") {
		delimiterType = 1
	} else if (delim == "Commas") {
		delimiterType = 2
	} else if (delim == "Pipes") {
		delimiterType = 3
	}
	pq = "true"
	if (processQuotes == FALSE) {
		pq = "false"
	}
	sf = "false"
	if (addSuffix == TRUE) {
		sf = "true"
	}
	json <- paste0("[\n {\"name\": \"tableName\",\n\"value\": \"",tableName,"\"},\n {\"name\": \"delimiterType\",\n\"value\": \"",delimiterType,"\"},{\"name\": \"processQuotes\",\n \"value\": ",pq,"},{\"name\": \"headerRow\",\n \"value\": \"",headerRow,"\"},{\"name\": \"dataRow\",\n \"value\": \"",dataRow,"\"},{\"name\": \"commentString\",\"value\": \"",commentString,"\"},\n {\"name\": \"columnForID\",\"value\": \"",columnForID,"\"},\n {\"name\": \"addSuffix\",\"value\": ",sf,"},\n {\"name\": \"tableType\",\"value\": \"",tableType,"\"},\n {\"name\": \"species\",\"value\": \"",species,"\"}\n]")
	params <- list(de=platformFolder,
				   format="Tabular (*.txt, *.xls, *.tab, etc.)",
				   fileID=fileID,
				   jobID=jobID,
				   json=json,
				   type="import"
			  )
	resp <- gx.imp$biouml.query("/web/import", params=params)
	resp
}

#' List contents of platform folder
#' 
#' This function returns a list of contents of specified folder.
#' Project folders are usually located under \emph{data/Projects}.
#' The \emph{extended} output contains in addition an indicator whether
#' a folder element has further child elements and the type of the element.
#'
#' @param path path of folder to list
#' @param extended get extended info including data types and whether folders have children
#' @return a list of contents of specified folder
#' @keywords ls
#' @seealso \code{\link[rbiouml]{biouml.ls}}
#' @export
gx.ls <- function(path, extended=F) {
    gx.getConnection()
    rbiouml::biouml.ls(path, extended)
}

#' Execute analysis using one of the integrated tools
#' 
#' This function invokes an analysis tool with specified parameters.
#'
#' The function can \emph{wait} for the analysis to complete (default) or
#' just invoke the analysis asynchronously. In the latter case it may be desireable
#' to keep the \emph{platform job id}, which is returned by this function, to
#' be able to request the job status. Analysis progress can be observed by
#' setting \code{verbose=T} (default).
#' The function \emph{gx.analysis.parameters} shows available parameters for an analysis tool
#' and \emph{gx.analysis.list} lists the available tools.
#' 
#'
#' @param analysisName name of analysis tool
#' @param parameters parameters to configure the analysis
#' @param wait TRUE to wait for the analysis to complete. Default: TRUE
#' @param verbose TRUE to see some progress info. Default: TRUE
#' @return the job id of the submitted task. The job id can be used to retrieve information about the status of the analysis. 
#' @keywords analysis
#' @seealso \code{\link{gx.analysis.list}}
#' @seealso \code{\link{gx.analysis.parameters}}
#' @seealso \code{\link[rbiouml]{biouml.analysis}}
#' @export
gx.analysis <- function(analysisName, parameters=list(), wait=T, verbose=T) {
    gx.getConnection()
    rbiouml::biouml.analysis(analysisName, parameters, wait, verbose)
}

#' Lists available analysis tools
#' 
#' Returns a list containing the available analysis tools
#' and their tool group. Tools are organized into thematic groups
#' like \emph{Data manipulation} or \emph{Site analysis}.
#'
#' @return a list containing available analysis tools and their tool group
#' @keywords analysis, list
#' @seealso \code{\link{gx.analysis}}
#' @seealso \code{\link{gx.analysis.parameters}}
#' @seealso \code{\link[rbiouml]{biouml.analysis.list}}
#' @export
gx.analysis.list <- function() {
    gx.getConnection()
    rbiouml::biouml.analysis.list()
}

#' Shows parameters for the specified analysis tool
#' 
#' Returns a list with parameter names and descriptions. 
#'
#' @param analysisName  name of the analysis tool
#' @return a list with parameter names and descriptions
#' @keywords analysis, parameters
#' @seealso \code{\link{gx.analysis}}
#' @seealso \code{\link{gx.analysis.list}}
#' @seealso \code{\link[rbiouml]{biouml.analysis.parameters}}
#' @export
gx.analysis.parameters <- function(analysisName) {
    gx.getConnection()
    gx.imp <- gx.getInternals()
    gx.imp$biouml.parameters("/web/bean/get", 
                             params = c(de = paste0("properties/method/parameters/", analysisName),
                             showMode = 1))
}

#' Executes workflow with specified parameters
#' 
#' This function invokes a workflow with specified parameters. A workflow
#' is identified by its path in the platform workspace, e.g. many workflows are provided
#' under \emph{analyses/Workflows}.
#'
#' The function can \emph{wait} for the analysis to complete (default) or
#' just invoke the analysis asynchronously. In the latter case it may be desireable
#' to keep the \emph{platform job id}, which is returned by this function, to
#' be able to request the job status. Analysis progress can be observed by
#' setting \code{verbose=T} (default).
#' Currently there is no workflow complement for \emph{gx.analysis.parameters} to inspect workflow
#' parameters. Workflow parameters are specified as shown in the platform web interface
#' and parameter names can be listed using \emph{gx.ls}, but the output also contains other
#' elements besides analysis parameters.
#'
#' @param path        platform path to the workflow
#' @param parameters  workflow parameters
#' @param wait        set true to wait for task to complete
#' @param verbose     switch to get more or less progress info
#' @return the job id of submitted task. The job id can be used to retrieve information about the status of the analysis.
#' @keywords workflow
#' @seealso \code{\link{gx.analysis}}
#' @seealso \code{\link{gx.ls}}
#' @seealso \code{\link[rbiouml]{biouml.workflow}}
#' @export
gx.workflow <- function(path, parameters=list(), wait=T, verbose=T) {
    gx.getConnection()
    rbiouml::biouml.workflow(path, parameters, wait, verbose)
}

#' Exports item using specified exporter
#' 
#' This function exports a specified item from the platform workspace
#' to a local file.
#' The function \emph{gx.exporters} lists available exporters and the
#' parameters of an exporter can be inspected using the function \emph{gx.export.parameters}.
#'
#' @param path            platform path of item to export
#' @param exporter        exporter to use for export
#' @param exporter.params parameters of the exporter
#' @param target.file     local file to export to
#' @return \code{NULL}
#' @keywords export
#' @seealso \code{\link{gx.exporters}}
#' @seealso \code{\link{gx.export.parameters}}
#' @seealso \code{\link[rbiouml]{biouml.export}}
#' @export
gx.export <- function(path, exporter="Tab-separated text (*.txt)", exporter.params=list(), target.file="genexplain.out") {
    gx.getConnection()
    rbiouml::biouml.export(path, exporter, exporter.params, target.file)
}

#' Lists available exporters
#'
#' Returns a vector with exporter names. An exporter transfers an item
#' from the platform workspace to a local file in a certain format.
#' Further information about exporters can be obtained in the context
#' of data items to export using \emph{gx.export.parameters}.
#'
#' @return a vector with exporter names
#' @keywords exporter, list
#' @seealso \code{\link{gx.export}}
#' @seealso \code{\link{gx.export.parameters}}
#' @seealso \code{\link[rbiouml]{biouml.exporters}}
#' @export
gx.exporters <- function() {
    gx.getConnection()
    rbiouml::biouml.exporters()
}

#' Returns parameters defined for given export and path to export from
#' 
#' Given the path of an item to export, this function shows the
#' parameters for a selected exporter.
#'
#' @param path     path of the object to export
#' @param exporter exporter to use for the export
#' @return a list with parameter names and descriptions
#' @keywords exporter, parameters
#' @seealso \code{\link{gx.export}}
#' @seealso \code{\link{gx.exporters}}
#' @seealso \code{\link[rbiouml]{biouml.export.parameters}}
#' @export
gx.export.parameters <- function(path, exporter) {
    gx.getConnection()
    rbiouml::biouml.export.parameters(path, exporter)
}

#' Gets a table from the platform workspace
#'
#' Returns a list containing the specified table.
#'
#' @param path  path of object to load into a data.frame
#' @return a list containing the table
#' @keywords get
#' @seealso \code{\link[rbiouml]{biouml.get}}
#' @export
gx.get <- function(path) {
    gx.getConnection()
    rbiouml::biouml.get(path)
}

#' Uploads a table to the platform
#'
#' This function stores a data frame in the specified path
#' of the platform workspace.
#'
#' @param path    platform path of new table
#' @param value   R object to put into platform 
#' @return \code{NULL} 
#' @keywords put
#' @seealso \code{\link[rbiouml]{biouml.put}}
#' @export
gx.put <- function(path, value) {
    gx.getConnection()
    rbiouml::biouml.put(path, value)
}

#' Imports a file into the platform
#' 
#' This function uploads a file into the platform using 
#' the specified importer configured by its
#' parameters.
#' The function \emph{gx.importers} lists the available
#' importers. Parameters for a specific importer can
#' be inspected using the \emph{gx.import.parameters} function.
#'
#' @param file            local file to import
#' @param parentPath      path of folder to import into
#' @param importer        importer to use
#' @param importer.params parameters for specified importer
#' @return the platform path of the imported item
#' @keywords import
#' @seealso \code{\link{gx.importers}}
#' @seealso \code{\link{gx.import.parameters}}
#' @seealso \code{\link[rbiouml]{biouml.import}}
#' @export
gx.import <- function(file, parentPath, importer, importer.params=list()) {
    gx.getConnection()
    rbiouml::biouml.import(file, parentPath, importer, importer.params)
}

#' Lists available importers
#' 
#' Returns a vector with available importer names. An importer
#' uploads a file to the platform, where it is imported as a
#' certain data type, e.g. as pathway or molecular network.
#'
#' @return a vector with available importers
#' @keywords importer, list
#' @seealso \code{\link{gx.import}}
#' @seealso \code{\link{gx.import.parameters}}
#' @seealso \code{\link[rbiouml]{biouml.importers}}
#' @export
gx.importers <- function() {
    gx.getConnection()
    rbiouml::biouml.importers()
}

#' Returns  parameters defined for given importer and path to import to
#' 
#' Given the path to import into, this function returns a list with
#' parameter names and description for a selected importer type.
#'
#' @param path      path to import to
#' @param importer  importer whose parameters will be shown
#' @return a list with parameter names and description
#' @keywords import, parameters
#' @seealso \code{\link{gx.import}}
#' @seealso \code{\link{gx.importers}}
#' @seealso \code{\link[rbiouml]{biouml.import.parameters}}
#' @export
gx.import.parameters <- function(path, importer) {
    gx.getConnection()
    rbiouml::biouml.import.parameters(path, importer)
}

#' Signs into geneXplain platform
#'
#' Starts a platform session by signing in with specified credentials.
#'
#' @param server   server to connect to
#' @param user     username
#' @param password password
#' @return a list with login parameters and session id
#' @keywords login
#' @seealso \code{\link[rbiouml]{biouml.login}}
#' @export
gx.login <- function(server='https://platform.genexplain.com', user='', password='') {
    rbiouml::biouml.login(server,user,password)
}

#' Terminates an existing platform session
#' 
#' Signs out of a platform session.
#'
#' @return \code{NULL}
#' @keywords logout
#' @seealso \code{\link[rbiouml]{biouml.logout}}
#' @export
gx.logout <- function() {
    rbiouml::biouml.logout()
}

#' Gets status info for a job running on the platform
#' 
#' This function retrieves status information for a task running
#' on the platform. A common use case is to check the status of
#' tasks invoked asynchronously using \emph{gx.analysis} and \emph{gx.workflow} with
#' \code{wait=F}.
#'
#' @param jobID  id of the platform task
#' @return a list with status info, response type of the job, the requested result and the analysis log
#' @keywords job, info
#' @seealso \code{\link[rbiouml]{biouml.job.info}}
#' @export
gx.job.info <- function(jobID) {
    gx.getConnection()
    rbiouml::biouml.job.info(jobID)
}

gx.job.wait <- function(jobID, verbose=T) {
    gx.getConnection()
    resp   = ""
    conAtt = 0
    ok     = F
    while (ok == F & conAtt <= connectionAttempts) {
        conAtt = conAtt+1
        tryCatch({
            resp <- rbiouml::biouml.job.wait(jobID, verbose)
        }, warning = function(w) {
            if (verbose) {
                print(w)
            }
        }, error = function(e) {
            print(e)
            next
        })
        ok = T
    }
    resp
}

gx.getConnection <- function() { 
    cnx <- getOption("biouml_connection")
    if(is.null(cnx))
        stop("Not signed into platform, please login first using gx.login()")
    cnx
}
                               
#' Finds out if a function exists
#'
#' This function finds out whether a function exists within the geneXplainR package or not.
#'
#' @param name       name of a possible function
#' @keywords         exist, function
#' @export
gx.exists <- function(name) {
  conI <- exists(name, where="package:geneXplainR", mode="function")
  gx.name <- paste0("gx.",name)
  conII <- exists(gx.name, where="package:geneXplainR", mode="function")
  if (conI | conII){
    cat("TRUE")
  } else {
    cat("FALSE")
  }
}

#' Finds out if an item is part of a folder
#'
#' This function checks whether an item exists in a certain path. 
#'
#' @param path        platform path
#' @param name        name of the item
#' @keywords          isElement, exist, item, path
#' @export
gx.isElement <- function(path, name) {
  elist <- gx.ls(path)
  is.element(name, elist)
}
