library(rbiouml)

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

gx.analysis.list <- function(...) {
    biouml.analysis.list(...)
}

gx.analysis.parameters <- function(...) {
    biouml.analysis.parameters(...)
}

gx.workflow <- function(...) {
    biouml.workflow(...)
}

gx.export <- function(...) {
    biouml.export(...)
}

gx.exporters <- function(...) {
    biouml.exporters(...)
}

gx.exporters.parameters <- function(...) {
    biouml.exporters.parameters(...)
}

gx.get <- function(...) {
    biouml.get(...)
}

gx.put <- function(...) {
    biouml.put(...)
}

gx.import <- function(...) {
    biouml.import(...)
}

gx.importers <- function(...) {
    biouml.importers(...)
}

gx.import.parameters <- function(...) {
    biouml.import.parameters(...)
}

gx.login <- function(...) {
    biouml.login(...)
}

gx.logout <- function(...) {
    biouml.logout(...)
}

gx.job.info <- function(...) {
    biouml.job.info(...)
}

gx.job.wait <- function(...) {
    biouml.job.wait(...)
}

gx.query <- function(serverPath, params=character(), binary=F) { 
    con <- getConnection()
    opts <- curlOptions( httpheader=paste("Cookie: JSESSIONID=", con$sessionId, sep='') )
    url <- paste(con$url, serverPath, sep='') 
    postForm(url, .params=params, .opts=opts, binary=binary)
}

getConnection <- function() { 
    con <- getOption("biouml_connection")
    if(is.null(con)) stop("Not logged in to platform, please login first using gx.login()")
    con
}

