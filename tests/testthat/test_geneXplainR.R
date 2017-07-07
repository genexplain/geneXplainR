
#############################################################
# Copyright (c) 2017 geneXplain GmbH, Wolfenbuettel, Germany
#
# Author: Philip Stegmaier
#
# Please see license that accompanies this software.
#############################################################

library(geneXplainR)
library(RJSONIO)

test.server <- "https://test.server"
test.user   <- "test.user"
test.passwd <- "test.password"

# Global objects
queryArgs     <<- list()
queryJsonArgs <<- list()

defaultQueryValue <<- "{\"type\":0,\"values\":\"\"}"
iioumlQueryValue  <<- defaultQueryValue

queryJSONValue   <<- function(simplify=T, reconnect=T) {
    fromJSON(bioumlQueryValue, simplify=simplify, asText=T)
}

# Overriding biouml.query function
test.biouml.query <- function(serverPath, params=character(), binary=F) {
    queryArgs <<- list(
            query   = serverPath,
            params  = params,
            binary  = binary)
    bioumlQueryValue
}

# Overriding biouml.queryJSON function
test.queryJSON <- function(serverPath, params=list(), simplify=T, reconnect=T) {
	queryJsonArgs <<- list(
            query     = serverPath,
            params    = params,
            simplify  = simplify,
            reconnect = reconnect)
    if (serverPath == "/web/table/columns") {
        bioumlQueryValue <<- "{\"type\":0,\"values\":[{\"name\":\"ID\",\"referenceType\":\"Genes: Ensembl\",\"type\":\"Text\",\"jsName\":\"ID\"},{\"name\":\"Test value\",\"type\":\"Text\",\"jsName\":\"Test value\"}]}"
    } else if (serverPath == "/web/table/rawdata") {
        bioumlQueryValue <<- "{\"type\":0,\"values\":[[\"Gene 1\",\"Gene 2\",\"Gene 3\"],[\"Value 1\",\"Value 2\",\"Value 3\"]]}"
    }
    queryJSONValue(simplify, reconnect)
}

# Overriding biouml.reconnect function
test.biouml.reconnect <- function(con=NULL) {
	if (is.null(con)) {
		con <- list(url  = paste(test.server,"/biouml"),
				    user = test.user,
		            pass = test.passwd);
	}
	con
}

# Initializes connection before a test
before.test.connection <- function() {
    options(biouml_connection = test.biouml.reconnect())
}

# Resets argument containers before a test
clean.after.test <- function() {
    queryArgs     <<- list()
    queryJsonArgs <<- list()
}

# Assign overriding functions
# These functions need to be mocked to enable testing
assignInNamespace("biouml.query", test.biouml.query,ns="rbiouml")
assignInNamespace("queryJSON", test.queryJSON, ns="rbiouml")
assignInNamespace("biouml.reconnect", test.biouml.reconnect, ns="rbiouml")


#
# Tests
#
test_that("gx.login", {
            before.test.connection()
            res <- gx.login(test.server,test.user,test.passwd)
            expect_equal(res$url,paste(test.server,"/biouml",sep=""))
            expect_equal(res$user,test.user)
            expect_equal(res$pass,test.passwd)
            clean.after.test()
        })

test_that("gx.logout", {
            before.test.connection()
            bioumlQueryValue <<- defaultQueryValue
			gx.logout()
            expect_equal(queryJsonArgs$query,"/web/logout")
            clean.after.test()
		})

test_that("gx.createProject", {
            before.test.connection()
            gx.createProject("test.name", "test.description")
            expect_equal(queryArgs$query, "/support/createProjectWithPermission")
            expect_equal(queryArgs$params$user, test.user)
            expect_equal(queryArgs$params$pass, test.passwd)
            expect_equal(queryArgs$params$project, "test.name")
            expect_equal(queryArgs$params$description, "test.description")
            clean.after.test()
        })

test_that("gx.createFolder", {
            before.test.connection()
            res <- gx.createFolder("test.path", "test.folder")
            expect_equal(queryJsonArgs$query, "/web/data")
            expect_equal(queryJsonArgs$params$service, "access.service")
            expect_equal(queryJsonArgs$params$command, "25")
            expect_equal(queryJsonArgs$params$dc, "test.path")
            expect_equal(queryJsonArgs$params$de, "test.folder")
            clean.after.test()
        })

test_that("gx.delete", {
            before.test.connection()
            bioumlQueryValue <<- defaultQueryValue
            gx.delete("test.folder", "test.name")
            expect_equal(queryJsonArgs$query, "/web/data")
            expect_equal(queryJsonArgs$params$service, "access.service")
            expect_equal(queryJsonArgs$params$command, "26")
            expect_equal(queryJsonArgs$params$dc, "test.folder")
            expect_equal(queryJsonArgs$params$de, "test.name")
            clean.after.test()
        })


test_that("gx.ls", {
            before.test.connection()
            bioumlQueryValue <<- "{\"type\":0,\"values\":\"{\\\"names\\\":[{\\\"name\\\":\\\"test-folder-1\\\"},{\\\"name\\\":\\\"test-folder-2\\\"}]}\"}"
            res <- gx.ls("test.path")
            expect_equal(length(res), 2)
            expect_equal(res[1], "test-folder-1")
            expect_equal(res[2], "test-folder-2")
            expect_equal(queryJsonArgs$query, "/web/data")
            expect_equal(queryJsonArgs$params$service, "access.service")
            expect_equal(queryJsonArgs$params$command, 29)
            expect_equal(queryJsonArgs$params$dc, "test.path")
            clean.after.test()
        })

test_that("gx.ls with extended output", {
            before.test.connection()
            bioumlQueryValue <<- "{\"type\":0,\"values\":\"{\\\"names\\\":[{\\\"hasChildren\\\":true,\\\"permissions\\\":7,\\\"name\\\":\\\"test-folder-1\\\",\\\"protection\\\":2,\\\"class\\\":0},{\\\"hasChildren\\\":false,\\\"permissions\\\":7,\\\"name\\\":\\\"test-folder-2\\\",\\\"protection\\\":2,\\\"class\\\":0}],\\\"size\\\":2,\\\"classes\\\":[\\\"biouml.model.Module\\\"],\\\"from\\\":0,\\\"to\\\":2,\\\"enabled\\\":true}\"}"
            res <- gx.ls("test.extended.path",T)
            expect_equal(length(res), 2)
            expect_equal(rownames(res)[1], "test-folder-1")
            expect_equal(rownames(res)[2], "test-folder-2")
            expect_true(res[1,1])
            expect_false(res[2,1])
            expect_equal(queryJsonArgs$query, "/web/data")
            expect_equal(queryJsonArgs$params$service, "access.service")
            expect_equal(queryJsonArgs$params$command, 29)
            expect_equal(queryJsonArgs$params$dc, "test.extended.path")
            clean.after.test()
        })

test_that("gx.analysis", {
            before.test.connection()
            bioumlQueryValue <<- defaultQueryValue
            res <- gx.analysis("test.analysis", list("test.param.1"="A","test.param.2"="B"), F, F)
            expect_equal(substr(res,1,4),"RJOB")
            expect_equal(queryJsonArgs$query, "/web/analysis")
            expect_equal(as.character(queryJsonArgs$params[2]), "test.analysis")
            clean.after.test()
        })

test_that("gx.analysis.list", {
            before.test.connection()
            bioumlQueryValue <<- "{\"type\":0,\"values\":[\"test.group.1/test.analysis.1\",\"test.group.2/test.analysis.2\",\"test.group.2/test.analysis.3\",\"test.group.3/test.analysis.4\"]}"
            res <- gx.analysis.list()
            expect_equal(queryJsonArgs$query, "/web/analysis/list")
            expect_equal(as.character(res[1,1]), "test.group.1")
            expect_equal(as.character(res[2,2]), "test.analysis.2")
            expect_equal(as.character(res[4,1]), "test.group.3")
            expect_equal(as.character(res[4,2]), "test.analysis.4")
            clean.after.test()
        })

test_that("gx.analysis.parameters", {
            before.test.connection()
            bioumlQueryValue <<- "{\"values\":[{\"name\":\"test.parameter.1\",\"description\":\"Test parameter 1\",\"type\":\"data-element-path\"},{\"name\":\"test.parameter.2\",\"description\":\"Test parameter 2\",\"type\":\"code-string\"},{\"description\":\"Test parameter 3\",\"type\":\"data-element-path\",\"name\":\"test.parameter.3\"}],\"type\":0}"
            res <- gx.analysis.parameters("test.analysis")
            expect_equal(queryJsonArgs$query, "/web/bean/get")
            expect_equal(as.character(queryJsonArgs$params[1]),"properties/method/parameters/test.analysis")
            expect_equal(rownames(res)[1],"test.parameter.1")
            expect_equal(rownames(res)[2],"test.parameter.2")
            expect_equal(rownames(res)[3],"test.parameter.3")
            expect_equal(as.character(res[1,1]),"Test parameter 1")
            expect_equal(as.character(res[2,1]),"Test parameter 2")
            expect_equal(as.character(res[3,1]),"Test parameter 3")
            clean.after.test()
        })

test_that("gx.workflow", {
            before.test.connection()
            bioumlQueryValue <<- defaultQueryValue
            res <- gx.workflow("test/workflow/path", list("test.parameter.1"="test.value.1","test.parameter.2"="test.value.2"),F,F)
            expect_equal(substr(res,1,4), "RJOB")
            expect_equal(queryJsonArgs$query, "/web/research")
            expect_equal(as.character(queryJsonArgs$params[2]), "start_workflow")
            expect_equal(as.character(queryJsonArgs$params[3]), "test/workflow/path")
            clean.after.test()
        })  
            
test_that("gx.export", {
            before.test.connection()
            bioumlQueryValue <<- defaultQueryValue
            res <- gx.export("test/export/path", "test.exporter", list("test.exporter.param"="test.exporter.value"), "test.export.file")
            expect_equal(queryArgs$query, "/web/export")
            expect_equal(queryArgs$params$exporter, "test.exporter")
            expect_equal(queryArgs$params$de, "test/export/path")
            clean.after.test()
        })

test_that("gx.export.parameters", {
            before.test.connection()
            bioumlQueryValue <<- "{\"values\":[{\"name\":\"test.export.parameter.1\",\"description\":\"Test export parameter 1\",\"type\":\"data-element-path\"},{\"name\":\"test.export.parameter.2\",\"description\":\"Test export parameter 2\",\"type\":\"code-string\"},{\"description\":\"Test export parameter 3\",\"type\":\"data-element-path\",\"name\":\"test.export.parameter.3\"}],\"type\":0}"
            res <- gx.export.parameters("test/export/path", "test.exporter")
            expect_equal(queryJsonArgs$query, "/web/export")
            expect_equal(as.character(queryJsonArgs$params[1]), "test/export/path")
            expect_equal(as.character(queryJsonArgs$params[4]), "test.exporter")
            expect_equal(rownames(res)[1],"test.export.parameter.1")
            expect_equal(rownames(res)[2],"test.export.parameter.2")
            expect_equal(rownames(res)[3],"test.export.parameter.3")
            expect_equal(as.character(res[1,1]),"Test export parameter 1")
            expect_equal(as.character(res[2,1]),"Test export parameter 2")
            expect_equal(as.character(res[3,1]),"Test export parameter 3")
            clean.after.test()
        })

test_that("gx.get", {
            before.test.connection()
            res <- gx.get("test/table/path")
            expect_equal(queryJsonArgs$query, "/web/table/rawdata")
            expect_equal(as.character(queryJsonArgs$params[1]), "test/table/path")
            expect_equal(rownames(res)[1],"Gene 1")
            expect_equal(rownames(res)[2],"Gene 2")
            expect_equal(rownames(res)[3],"Gene 3")
            expect_equal(colnames(res)[1],"Test value")
            expect_equal(res[1,1], "Value 1")
            expect_equal(res[2,1], "Value 2")
            expect_equal(res[3,1], "Value 3")
            clean.after.test()
        })


test_that("gx.put", {
            before.test.connection()
            bioumlQueryValue <<- defaultQueryValue
            res <- gx.put("test/table/path",data.frame("Test.value"=c(1,2,3),row.names=c("Gene 1", "Gene 2", "Gene 3")))
            expect_equal(queryJsonArgs$query, "/web/table/createTable")
            expect_equal(as.character(queryJsonArgs$params[1]), "test/table/path")
            cols <- fromJSON(as.character(queryJsonArgs$params[2]))
            expect_equal(as.character(cols[[1]]["name"]),"ID")
            expect_equal(as.character(cols[[2]]["name"]),"Test.value")
            data <- fromJSON(as.character(queryJsonArgs$params[3]))
            expect_equal(as.character(data[[1]][1]),"Gene 1")
            expect_equal(as.character(data[[1]][2]),"Gene 2")
            expect_equal(as.character(data[[1]][3]),"Gene 3")
            expect_equal(data[[2]][1],1)
            expect_equal(data[[2]][2],2)
            expect_equal(data[[2]][3],3)
            clean.after.test()
        })

test_that("gx.import", {
            before.test.connection()
            clean.after.test()
        })

test_that("gx.importers", {
            before.test.connection()
            bioumlQueryValue <<- "{\"type\":0,\"values\":[\"Test importer 1\",\"Test importer 2\",\"Test importer 3\"]}"
            res <- gx.importers()
            expect_equal(queryJsonArgs$query, "/web/import/list")
            expect_equal(as.character(res[1]),"Test importer 1")
            expect_equal(as.character(res[2]),"Test importer 2")
            expect_equal(as.character(res[3]),"Test importer 3")
            clean.after.test()
        })

test_that("gx.import.parameters", {
            before.test.connection()
            bioumlQueryValue <<- "{\"values\":[{\"displayName\":\"Test parameter\",\"name\":\"test parameter\",\"description\":\"A test parameter.\",\"readOnly\":false}],\"attributes\":{\"expertOptions\":false},\"type\":0}"
            res <- gx.import.parameters("test/import/path", "test.importer")
            expect_equal(queryJsonArgs$query, "/web/import")
            expect_equal(as.character(queryJsonArgs$params['de']), "test/import/path")
            expect_equal(as.character(queryJsonArgs$params['format']), "test.importer")
            expect_equal(row.names(res)[1],"test parameter")
            clean.after.test()
        })

test_that("gx.job.info", {
            before.test.connection()
            bioumlQueryValue <<- defaultQueryValue
            res <- gx.job.info("RJOB1234")
            expect_equal(queryJsonArgs$query, "/web/jobcontrol")
            expect_equal(as.character(queryJsonArgs$params['jobID']), "RJOB1234")
            clean.after.test()
        })

test_that("gx.vennDiagrams", {
            before.test.connection()
            bioumlQueryValue <<- "{\"values\":[{\"canBeNull\":true,\"promptOverwrite\":false,\"displayName\":\"Left table (T1)\",\"name\":\"table1Path\",\"icon\":\"biouml.plugins.ensembl:biouml/plugins/ensembl/tabletype/resources/genes-ensembl.gif\",\"description\":\"Table which will be represented as left-top circle\",\"readOnly\":false,\"elementClass\":\"ru.biosoft.table.TableDataCollection\",\"type\":\"data-element-path\",\"value\":\"data/Examples/TNF-stimulation of HUVECs GSE2639, Affymetrix HG-U133A microarray/Data/DEGs with limma/Normalized (RMA) DEGs with EBarrays/Condition_2 upreg Ensembl\",\"elementMustExist\":true,\"multiSelect\":false},{\"canBeNull\":true,\"promptOverwrite\":false,\"displayName\":\"Right table (T2)\",\"name\":\"table2Path\",\"icon\":\"biouml.plugins.ensembl:biouml/plugins/ensembl/tabletype/resources/genes-ensembl.gif\",\"description\":\"Table which will be represented as right-top circle\",\"readOnly\":false,\"elementClass\":\"ru.biosoft.table.TableDataCollection\",\"type\":\"data-element-path\",\"value\":\"data/Examples/TNF-stimulation of HUVECs GSE2639, Affymetrix HG-U133A microarray/Data/DEGs with limma/Normalized (RMA) DEGs with limma/Condition_1 vs. Condition_2/Up-regulated genes Ensembl\",\"elementMustExist\":true,\"multiSelect\":false},{\"canBeNull\":true,\"promptOverwrite\":false,\"displayName\":\"Center table (T3)\",\"name\":\"table3Path\",\"icon\":\"ru.biosoft.table:ru/biosoft/table/resources/table.gif\",\"description\":\"Table which will be represented as center-bottom circle\",\"readOnly\":false,\"elementClass\":\"ru.biosoft.table.TableDataCollection\",\"type\":\"data-element-path\",\"value\":\"(select element)\",\"elementMustExist\":true,\"multiSelect\":false},{\"displayName\":\"Simple picture\",\"name\":\"simple\",\"description\":\"All circles has equal radius\",\"readOnly\":false,\"type\":\"bool\",\"value\":\"true\"},{\"auto\":\"off\",\"displayName\":\"Output path\",\"icon\":\"ru.biosoft.access:ru/biosoft/access/resources/collection.gif\",\"description\":\"Folder name to store the results\",\"readOnly\":false,\"type\":\"data-element-path\",\"canBeNull\":false,\"promptOverwrite\":false,\"name\":\"output\",\"elementClass\":\"ru.biosoft.access.FolderCollection\",\"value\":\"data/Projects/ncRNA analysis/Data/Venn-test-4\",\"elementMustExist\":false,\"multiSelect\":false}],\"attributes\":{\"expertOptions\":true},\"type\":0}"
            res <- gx.vennDiagrams("test.table1","test.table2",table1Name="test.table1.name",table2Name="test.table2.name",output="test.output",wait=F,verbose=F)
            expect_equal(queryJsonArgs$query, "/web/analysis")
            expect_equal(as.character(queryJsonArgs$params['de']), "Venn diagrams")
            clean.after.test()
        })

test_that("gx.classifyChipSeqTargets", {
              before.test.connection()
              res <- gx.classifyChipSeqTargets(inputTrack="test.track",species="test.species",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/Common/ChIP-Seq - Identify and classify target genes")
              clean.after.test()
        })

test_that("gx.mapGenesToOntologies", {
              before.test.connection()
              res <- gx.mapGenesToOntologies(inputTable="test.table",species="test.species",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/Common/Mapping to ontologies (Gene table)")
              clean.after.test()
        })


test_that("gx.explainMyGenes", {
              before.test.connection()
              res <- gx.explainMyGenes(inputTable="test.table",species="test.species",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/Common/Explain my genes")
              clean.after.test()
        })

test_that("gx.limmaWorkflow", {
              before.test.connection()
              res <- gx.limmaWorkflow(inputTable="test.table",probeType="test.probes",species="test.species",
                                      conditions=list("Condition_1"="Test","Condition_2"="Control","1_Columns"=c("col1","col2"),"2_Columns"=c("col3","col4")),
                                      resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/Common/Compute differentially expressed genes using Limma")
              clean.after.test()
        })

test_that("gx.ebarraysWorkflow", {
              before.test.connection()
              res <- gx.ebarraysWorkflow(inputTable="test.table",probeType="test.probes",species="test.species",
                                      controlName="test.control",controlColumns=c("test.col.1","test.col.2"),
                                      conditions=list("group_1"="Test","group_2"="Test_2","Columns_group_1"=c("col1","col2"),"Columns_group_2"=c("col3","col4")),
                                      resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/Common/Compute differentially expressed genes using EBarrays")
              clean.after.test()
        })

test_that("gx.enrichedTFBSGenes", {
              before.test.connection()
              res <- gx.enrichedTFBSGenes(inputYesSet="test.yes",inputNoSet="test.no",species="test.species",
                                          profile="test.profile",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/TRANSFAC/Identify enriched motifs in promoters (TRANSFAC(R))")
              clean.after.test()
        })

test_that("gx.upstreamAnalysisTransfacGeneWays", {
              before.test.connection()
              res <- gx.upstreamAnalysisTransfacGeneWays(inputYesSet="test.yes",inputNoSet="test.no",species="test.species",
                                                         profile="test.profile",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/TRANSFAC/Upstream analysis (TRANSFAC(R) and GeneWays)")
              clean.after.test()
        })

test_that("gx.upstreamAnalysisTransfacTranspath", {
              before.test.connection()
              res <- gx.upstreamAnalysisTransfacTranspath(inputYesSet="test.yes",inputNoSet="test.no",species="test.species",
                                                          profile="test.profile",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/TRANSPATH/Upstream analysis (TRANSFAC(R) and TRANSPATH(R))")
              clean.after.test()
        })

test_that("gx.focusedUpstreamAnalysis", {
              before.test.connection()
              res <- gx.focusedUpstreamAnalysis(inputYesSet="test.yes",inputNoSet="test.no",species="test.species",
                                                profile="test.profile",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/TRANSPATH/Focused upstream analysis (TRANSFAC(R) and TRANSPATH(R))")
              clean.after.test()
        })


test_that("gx.enrichedUpstreamAnalysis", {
              before.test.connection()
              res <- gx.enrichedUpstreamAnalysis(inputYesSet="test.yes",inputNoSet="test.no",species="test.species",
                                                 profile="test.profile",resultFolder="test.folder",wait=F,verbose=F)
              expect_equal(as.character(queryJsonArgs$params['de']), "analyses/Workflows/TRANSPATH/Enriched upstream analysis (TRANSFAC(R) and TRANSPATH(R))")
              clean.after.test()
        })

