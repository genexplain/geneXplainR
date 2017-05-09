library(geneXplainR)

test.biouml.query <- function(serverPath, params=character(), binary=F) {
}

test.queryJSON <- function(serverPath, params=list(), simplify=T, reconnect=T) {
}

test.biouml.reconnect <- function(con) {
}

assignInNamespace("biouml.query", test.biouml.query,ns="rbiouml")
assignInNamespace("queryJSON", test.queryJSON, ns="rbiouml")
assignInNamespace("biouml.reconnect", test.biouml.reconnect, ns="rbiouml")

test_that("Trivial", { expect_that(1,equals(1)) })

