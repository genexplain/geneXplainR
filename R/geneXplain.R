#############################################################
# Copyright (c) 2017 geneXplain GmbH, Wolfenbuettel, Germany
#
# Author: Philip Stegmaier
#
# Please see license that accompanies this software.
#############################################################


gx.getInternals <- function() {
    .internals <- c("biouml.query", "queryJSON")
    gx.imp <- structure(mapply(function(.internals,i) getFromNamespace(i,"rbiouml"),.internals,.internals),class=c("internal"))
    gx.imp
}

connectionAttempts = 3

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
    gx.imp$biouml.query("/support/createProjectWithPermission", params=list(user=con$user, pass=con$pass, project=name, description=description)) }

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
    rbiouml::biouml.analysis.parameters(analysisName)
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
#' @keyword        exist, function
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
#' @keyword           isElement, exist, item, path
#' @export
gx.isElement <- function(path, name) {
  elist <- gx.ls(path)
  is.element(name, elist)
}
