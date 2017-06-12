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


#' Create a new project
#'
#' @param name name of the project
#' @param description a short description of the project
#' @export
gx.createProject <- function(name, description="New platform project") {
    con <- gx.getConnection()
    gx.imp <- gx.getInternals()
    gx.imp$biouml.query("/support/createProjectWithPermission", params=list(user=con$user, pass=con$pass, project=name, description=description)) }

#' Create a folder
#'
#' @param path        parent folder in which the new folder is created
#' @param folderName  name of the new folder 
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
#' @param folder folder that contains the item
#' @param name   name of the item
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
#' Wraps rbiouml function biouml.ls
#'
#' @param path path of folder to list
#' @param extended get extended info including data types and whether folders have children
#' @keywords ls
#' @seealso \code{\link[rbiouml]{biouml.ls}}
#' @export
gx.ls <- function(path, extended=F) {
    gx.getConnection()
    rbiouml::biouml.ls(path, extended)
}

#' Execute analysis using one of the integrated tools
#' 
#' Wraps rbiouml function biouml.analysis
#'
#' @param analysisName name of analysis tool
#' @param parameters parameters to configure the analysis
#' @param wait TRUE to wait for the analysis to complete. Default: TRUE
#' @param verbose TRUE to see some progress info. Default: TRUE
#' @keywords analysis
#' @seealso \code{\link[rbiouml]{biouml.analysis}}
#' @export
gx.analysis <- function(analysisName, parameters=list(), wait=T, verbose=T) {
    gx.getConnection()
    rbiouml::biouml.analysis(analysisName, parameters, wait, verbose)
}

#' Lists available analysis tools
#' 
#' Wraps rbiouml function biouml.analysis.list
#'
#' @keywords analysis, list
#' @seealso \code{\link[rbiouml]{biouml.analysis.list}}
#' @export
gx.analysis.list <- function() {
    gx.getConnection()
    rbiouml::biouml.analysis.list()
}

#' Shows parameters for the specified analysis tool
#' 
#' Wraps rbiouml function biouml.analysis.parameters
#'
#' @keywords analysis, parameters
#' @seealso \code{\link[rbiouml]{biouml.analysis.parameters}}
#' @export
gx.analysis.parameters <- function(analysisName) {
    gx.getConnection()
    rbiouml::biouml.analysis.parameters(analysisName)
}

#' Executes workflow with specified parameters
#' 
#' Wraps rbiouml function biouml.workflow
#'
#' @keywords workflow
#' @seealso \code{\link[rbiouml]{biouml.workflow}}
#' @export
gx.workflow <- function(path, parameters=list(), wait=T, verbose=T) {
    gx.getConnection()
    rbiouml::biouml.workflow(path, parameters, wait, verbose)
}

#' Exports item using specified exporter
#' 
#' Wraps rbiouml function biouml.export
#'
#' @keywords export
#' @seealso \code{\link[rbiouml]{biouml.export}}
#' @export
gx.export <- function(path, exporter="Tab-separated text (*.txt)", exporter.params=list(), target.file="genexplain.out") {
    gx.getConnection()
    rbiouml::biouml.export(path, exporter, exporter.params, target.file)
}

#' Lists available exporters
#' 
#' Wraps rbiouml function biouml.exporters
#'
#' @keywords exporter, list
#' @seealso \code{\link[rbiouml]{biouml.exporters}}
#' @export
gx.exporters <- function() {
    gx.getConnection()
    rbiouml::biouml.exporters()
}

#' Returns parameters defined for given export and path to export from
#' 
#' Wraps rbiouml function biouml.export.parameters
#'
#' @keywords exporter, parameters
#' @seealso \code{\link[rbiouml]{biouml.export.parameters}}
#' @export
gx.export.parameters <- function(path, exporter) {
    gx.getConnection()
    rbiouml::biouml.export.parameters(path, exporter)
}

#' Gets a table from the platform workspace into a data.frame
#' 
#' Wraps rbiouml function biouml.get
#'
#' @keywords get
#' @seealso \code{\link[rbiouml]{biouml.get}}
#' @export
gx.get <- function(path) {
    gx.getConnection()
    rbiouml::biouml.get(path)
}

#' Uploads a table to the platform
#' 
#' Wraps rbiouml function biouml.put
#'
#' @keywords put
#' @seealso \code{\link[rbiouml]{biouml.put}}
#' @export
gx.put <- function(path, value) {
    gx.getConnection()
    rbiouml::biouml.put(path, value)
}

#' Imports a file into the platform
#' 
#' Wraps rbiouml function biouml.import
#'
#' @keywords import
#' @seealso \code{\link[rbiouml]{biouml.import}}
#' @export
gx.import <- function(file, parentPath, importer, importer.params=list()) {
    gx.getConnection()
    rbiouml::biouml.import(file, parentPath, importer, importer.params)
}

#' Lists available importers
#' 
#' Wraps rbiouml function biouml.importers
#'
#' @keywords importer, list
#' @seealso \code{\link[rbiouml]{biouml.importers}}
#' @export
gx.importers <- function() {
    gx.getConnection()
    rbiouml::biouml.importers()
}

#' Returns parameters defined for given importer and path to import to
#' 
#' Wraps rbiouml function biouml.import.parameters
#'
#' @keywords import, parameters
#' @seealso \code{\link[rbiouml]{biouml.import.parameters}}
#' @export
gx.import.parameters <- function(path, importer) {
    gx.getConnection()
    rbiouml::biouml.import.parameters(path, importer)
}

#' Signs into geneXplain platform
#' 
#' Wraps rbiouml function biouml.login
#'
#' @keywords login
#' @seealso \code{\link[rbiouml]{biouml.login}}
#' @export
gx.login <- function(server='https://platform.genexplain.com', user='', password='') {
    rbiouml::biouml.login(server,user,password)
}

#' Terminates an existing platform session
#' 
#' Wraps rbiouml function biouml.logout
#'
#' @keywords logout
#' @seealso \code{\link[rbiouml]{biouml.logout}}
#' @export
gx.logout <- function() {
    rbiouml::biouml.logout()
}

#' Gets status info for a job running on the platform
#' 
#' Wraps rbiouml function biouml.job.info
#'
#' @keywords job, info
#' @seealso \code{\link[rbiouml]{biouml.job.info}}
#' @export
gx.job.info <- function(jobID) {
    gx.getConnection()
    rbiouml::biouml.job.info(jobID)
}

gx.job.wait <- function(jobID, verbose=T) {
    gx.getConnection()
    rbiouml::biouml.job.wait(jobID, verbose)
}

gx.getConnection <- function() { 
    cnx <- getOption("biouml_connection")
    if(is.null(cnx))
        stop("Not signed into platform, please login first using gx.login()")
    cnx
}

