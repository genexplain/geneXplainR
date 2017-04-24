#############################################################
# Copyright (c) 2017 geneXplain GmbH, Wolfenbuettel, Germany
#
# Please see license that accompanies this software.
#############################################################


#' Create a new project
#'
#' @param name name of the project
#' @param description a short description of the project
#' @export
#' @examples
#'
#' # Note that the project name probably requires adaptation
#'
#' gx.createProject("example-project","example description")
#'
gx.createProject <- function(name, description="New platform project") {
    con <- getConnection()
    gx.query("/support/createProjectWithPermission", params=list(user=con$user, pass=con$pass, project=name, description=description))
}

#' Delete a workspace item
#'
#' @param folder folder that contains the item
#' @param name   name of the item
#' @export
#' @examples
#'
#' # Note that the folder and name probably require adaptation
#'
#' gx.delete("example-folder","example-name")
#'
gx.delete <- function(folder, name) {
    params <- list("service" = "access.service",
                   "command" = "26",
                   "dc" = folder,
                   "de" =  name)
    gx.queryJSON("/web/data", params);
}

#' List contents of platform folder
#' 
#' Wraps rbiouml function biouml.ls
#'
#' @param path path of folder to list
#' @param extended get extended info including data types and whether folders have children
#' @keywords ls
#' @seealso \code{\link{rbiouml::biouml.ls}}
#' @export
#' @examples
#' gx.ls(path="data/Projects", extended=T)
#'
gx.ls <- function(path, extended=F) {
    biouml.ls(path, extended)
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
#' @seealso \code{\link{rbiouml::biouml.analysis}}
#' @export
#' @examples
#' gx.analysis()
#'
gx.analysis <- function(analysisName, parameters=list(), wait=T, verbose=T) {
    biouml.analysis(analysisName, parameters, wait, verbose)
}

#' Lists available analysis tools
#' 
#' Wraps rbiouml function biouml.analysis.list
#'
#' @keywords analysis, list
#' @seealso \code{\link{rbiouml::biouml.analysis.list}}
#' @export
#' @examples
#' gx.analysis.list()
#'
gx.analysis.list <- function() {
    biouml.analysis.list()
}

#' Shows parameters for the specified analysis tool
#' 
#' Wraps rbiouml function biouml.analysis.parameters
#'
#' @keywords analysis, parameters
#' @seealso \code{\link{rbiouml::biouml.analysis.parameters}}
#' @export
#' @examples
#' gx.analysis.parameters()
#'
gx.analysis.parameters <- function(analysisName) {
    biouml.analysis.parameters(analysisName)
}

#' Executes workflow with specified parameters
#' 
#' Wraps rbiouml function biouml.workflow
#'
#' @keywords workflow
#' @seealso \code{\link{rbiouml::biouml.workflow}}
#' @export
#' @examples
#' gx.workflow("path/to/example/workflow", list("param1"="value1"))
#'
gx.workflow <- function(path, parameters=list(), wait=T, verbose=T) {
    biouml.workflow(path, parameters, wait, verbose)
}

#' Exports item using specified exporter
#' 
#' Wraps rbiouml function biouml.export
#'
#' @keywords export
#' @seealso \code{\link{rbiouml::biouml.export}}
#' @export
#' @examples
#' gx.export()
#'
gx.export <- function(path, exporter="Tab-separated text (*.txt)", exporter.params=list(), target.file="genexplain.out") {
    biouml.export(path, exporter, exporter.params, target.file)
}

#' Lists available exporters
#' 
#' Wraps rbiouml function biouml.exporters
#'
#' @keywords exporter, list
#' @seealso \code{\link{rbiouml::biouml.exporters}}
#' @export
#' @examples
#' gx.exporters()
#'
gx.exporters <- function() {
    biouml.exporters()
}

#' Returns parameters defined for given export and path to export from
#' 
#' Wraps rbiouml function biouml.exporter.parameters
#'
#' @keywords exporter, parameters
#' @seealso \code{\link{rbiouml::biouml.exporter.parameters}}
#' @export
#' @examples
#' gx.exporter.parameters("example-path","example-exporter")
#'
gx.export.parameters <- function(path, exporter) {
    biouml.exporters.parameters(path, exporter)
}

#' Gets a table from the platform workspace into a data.frame
#' 
#' Wraps rbiouml function biouml.get
#'
#' @keywords get
#' @seealso \code{\link{rbiouml::biouml.get}}
#' @export
#' @examples
#' gx.get("example/table/path")
#'
gx.get <- function(path) {
    biouml.get(path)
}

#' Uploads a table to the platform
#' 
#' Wraps rbiouml function biouml.put
#'
#' @keywords put
#' @seealso \code{\link{rbiouml::biouml.put}}
#' @export
#' @examples
#' gx.put("example/destination/path",data)
#'
gx.put <- function(path, value) {
    biouml.put(path, value)
}

#' Imports a file into the platform
#' 
#' Wraps rbiouml function biouml.import
#'
#' @keywords import
#' @seealso \code{\link{rbiouml::biouml.import}}
#' @export
#' @examples
#' gx.import("example/file/path", "example/platform/path", "example-importer", list())
#'
gx.import <- function(file, parentPath, importer, importer.params=list()) {
    biouml.import(file, parentPath, importer, importer.params)
}

#' Lists available importers
#' 
#' Wraps rbiouml function biouml.importers
#'
#' @keywords importer, list
#' @seealso \code{\link{rbiouml::biouml.importers}}
#' @export
#' @examples
#' gx.importers()
#'
gx.importers <- function() {
    biouml.importers()
}

#' Returns parameters defined for given importer and path to import to
#' 
#' Wraps rbiouml function biouml.import.parameters
#'
#' @keywords import, parameters
#' @seealso \code{\link{rbiouml::biouml.import.parameters}}
#' @export
#' @examples
#' gx.import.parameters("example-path","example-importer")
#'
gx.import.parameters <- function(path, importer) {
    biouml.import.parameters(path, importer)
}

#' Signs into geneXplain platform
#' 
#' Wraps rbiouml function biouml.login
#'
#' @keywords login
#' @seealso \code{\link{rbiouml::biouml.login}}
#' @export
#' @examples
#' gx.login("example-server","example-user","example-password")
#'
gx.login <- function(server='https://platform.genexplain.com', user='', password='') {
    biouml.login(server,user,password)
}


#' Terminates an existing platform session
#' 
#' Wraps rbiouml function biouml.logout
#'
#' @keywords logout
#' @seealso \code{\link{rbiouml::biouml.logout}}
#' @export
#' @examples
#' gx.logout()
#'
gx.logout <- function() {
    biouml.logout()
}


#' Gets status info for a job running on the platform
#' 
#' Wraps rbiouml function biouml.job.info
#'
#' @keywords job, info
#' @seealso \code{\link{rbiouml::biouml.job.info}}
#' @export
#' @examples
#' gx.job.info("example-id")
#'
gx.job.info <- function(jobID) {
    biouml.job.info(jobID)
}

gx.job.wait <- function(jobID, verbose=T) {
    biouml.job.wait(jobID, verbose)
}

gx.query <- function(urlPath, params=character(), binary=F) { 
    cnx <- gx.getConnection()
    opt <- curlOptions( httpHeader=paste("Cookie: JSESSIONID=", cnx$sessionId, sep='') )
    url <- paste(cnx$url, apiPath, sep='') 
    postForm(url, .params=params, .opts=opt, binary=binary)
}

gx.getConnection <- function() { 
    cnx <- getOption("biouml_connection")
    if(is.null(cnx))
        stop("Not signed into platform, please login first using gx.login()")
    cnx
}

gx.reconnect <- function(con) {
    header <- basicHeaderGatherer()
    content <- basicTextGatherer()
    opts <- curlOptions(headerfunction=header$update, writefunction=content$update)
    postForm(paste(con$url, "/web/login", sep=''), username=con$user, password=con$pass, .opts=opts)
    contentJson <- fromJSON(content$value())
    if (contentJson$type != 0) 
        stop(contentJson$message);
    con$sessionId <- sub('JSESSIONID=([^;]+).*', '\\1', header$value()['Set-Cookie'])
    options(biouml_connection=con)
    con
}

gx.queryJSON <- function(serverPath, params=list(), simplify=T, reconnect=T) {
    content <- gx.query(serverPath, params)
    json <- fromJSON(content, simplify=simplify, asText=T)
    responseType <- as.numeric(as.list(json)$type)
    if ( responseType == 3 && reconnect ) {
        gx.reconnect(gx.getConnection())
        return(queryJSON(serverPath, params, simplify, reconnect=F))
    } else if(responseType != 0) {
        stop(as.list(json)$message)
    }
    json
}

