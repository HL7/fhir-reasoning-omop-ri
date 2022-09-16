#' @title Load addtional  Tables required for atlas, achillies and OmoponFHIR.
#'
#' @description This function runs a number of sql files
#'
#' @usage CreateOMOPonFHIRTables (connectionDetails, cdmSchema, vocabSchema,resultsSchema, sqlOnly)
#'
#' @details This function assumes \cr\code{createCDMTables()}, \cr\code{createSyntheaTables()}, \cr\code{LoadSyntheaTables()},
#'              and \cr\code{LoadVocabTables()} have all been run.
#'
#' @param connectionDetails  An R object of type\cr\code{connectionDetails} created using the
#'                                     function \code{createConnectionDetails} in the
#'                                     \code{DatabaseConnector} package.
#' @param cdmSchema  The name of the database schema that will contain the CDM.
#'                                     Requires read and write permissions to this database. On SQL
#'                                     Server, this should specifiy both the database and the schema,
#'                                     so for example 'cdm_instance.dbo'.
#' @param vocabSchema  The name of the database schema that contain the vocabulary data
#'                                     instance.  Requires read and write permissions to this database. On SQL
#'                                     Server, this should specifiy both the database and the schema,
#'                                     so for example 'cdm_instance.dbo'.
#' @param resultsSchema  The name of the database schema that will contain the results data created by atlas/achillies
#'                                     instance.  Requires read and write permissions to this database. On SQL
#'                                     Server, this should specifiy both the database and the schema,
#'                                     so for example 'cdm_instance.dbo'.
#' @param cdmVersion The version of your CDM.  Currently "5.3" and "5.4".
#' @param syntheaVersion The version of Synthea used to generate the csv files.
#'                       Currently "2.7.0" is supported.
#' @param sqlOnly A boolean that determines whether or not to perform the load or generate SQL scripts. Default is FALSE.
#'
#'@export


CreateOMOPonFHIRTables <- function (connectionDetails,
														 cdmSchema,
														 vocabSchema,
														 resultsSchema = "results",
														 cdmHolder = "OHDSI",
														 cdmSourceDescription = "SyntheaTM is a Synthetic Patient Population Simulator. The goal is to output synthetic, realistic (but not real), patient data and associated health records in a variety of formats.",
														 sqlOnly = FALSE)
{
	
	sqlFilePath <- "additional_sql"

	if (!sqlOnly) {
		conn <- DatabaseConnector::connect(connectionDetails)
	} else {
		if (!dir.exists("output")) {
			dir.create("output")
		}
	}

	runStep <- function(sql, fileQuery) {
		if (sqlOnly) {
			writeLines(paste0("Saving to output/", sql))
			SqlRender::writeSql(sql, paste0("output/", fileQuery))
		} else {
			writeLines(paste0("Running: ", fileQuery))
			DatabaseConnector::executeSql(conn, sql)
		}
	}



	fileQuery <- "omoponfhir_v5.2_f_immunization_view_ddl.sql"
	pathToSql <- file.path(sqlFilePath, fileQuery)
	parameterizedSql <- readChar(pathToSql, file.info(pathToSql)$size)
	
	sql <- SqlRender::render(parameterizedSql,
		cdmSchema = cdmSchema
	)
	runStep(sql, fileQuery)

	
	fileQuery <- "omoponfhir_v5.4_f_observation_ddl.sql"
	pathToSql <- file.path(sqlFilePath, fileQuery)
	parameterizedSql <- readChar(pathToSql, file.info(pathToSql)$size)
	
	sql <- SqlRender::render(parameterizedSql,
		cdmSchema = cdmSchema
	)
	runStep(sql, fileQuery)

	
	fileQuery <- "fhir_names/names.dmp"
	pathToSql <- file.path(sqlFilePath, fileQuery)
	parameterizedSql <- readChar(pathToSql, file.info(pathToSql)$size)
	runStep(parameterizedSql, fileQuery)
	
	fileQuery <- "results.sql"
	pathToSql <- file.path(sqlFilePath, fileQuery)
	parameterizedSql <- readChar(pathToSql, file.info(pathToSql)$size)
	
	sql <- SqlRender::render(parameterizedSql,
		resultsSchema = resultsSchema,
		vocabSchema = vocabSchema
	)
	runStep(sql, fileQuery)

	if (!sqlOnly) {
		DatabaseConnector::disconnect(conn)
	}
}