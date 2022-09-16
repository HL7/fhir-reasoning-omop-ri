synthea_db_host <- "host.docker.internal"
synthea_db_name <- "OHDSI-CDM_V54"
synthea_db_pass <- "clipper"
synthea_db_port <- 54320
synthea_db <- paste(synthea_db_host, synthea_db_name, sep="/")

devtools::install_github("OHDSI/CommonDataModel", "v5.4",  upgrade="always")
devtools::install_github("OHDSI/ETL-Synthea", upgrade="always")
# devtools::install_github("OHDSI/ETL-Synthea", upgrade="always")
library(ETLSyntheaBuilder)

cd <- DatabaseConnector::createConnectionDetails(
  dbms     = "postgresql", 
  server   = synthea_db, 
  user     = "postgres", 
  password = synthea_db_pass,
  port     = synthea_db_port, 
  pathToDriver = "/drivers"  
)

db <- DatabaseConnector::connect(cd)

cdmSchema      <- "cdm_synthea"
cdmVersion     <- "5.4"
syntheaVersion <- "2.7.0"
syntheaSchema  <- "native"
syntheaFileLoc <- "/synthea"
vocabFileLoc   <- "/vocabulary"
resultsSchema  <- "results"

# Check to see if the person table exists; use this as a proxy check for previous table creation
if (!DatabaseConnector::dbExistsTable(conn = db, name = "person", database = synthea_db_name, schema = cdmSchema)) { 
  print("==================== Running: CreateCDMTables ====================")
  ETLSyntheaBuilder::CreateCDMTables(connectionDetails = cd, cdmSchema = cdmSchema, cdmVersion = cdmVersion)
} else { 
  print("==================== Skipping: CreateCDMTables ====================")
  print("- Tables already exist")
}

# Check to see if the patients table exists; use this as a proxy check for previous table creation
if (!DatabaseConnector::dbExistsTable(conn = db, name = "patients", database = synthea_db_name, schema = syntheaSchema)) { 
  print("==================== Running: CreateSyntheaTables ====================")                                     
  ETLSyntheaBuilder::CreateSyntheaTables(connectionDetails = cd, syntheaSchema = syntheaSchema, syntheaVersion = syntheaVersion)
} else { 
  print("==================== Skipping: CreateSyntheaTables ====================")
  print("- Tables already exist")
}

print("==================== Running: LoadSyntheaTables ====================")                                       
ETLSyntheaBuilder::LoadSyntheaTables(connectionDetails = cd, syntheaSchema = syntheaSchema, syntheaFileLoc = syntheaFileLoc)

print("==================== Running: LoadVocabFromCsv ====================")
ETLSyntheaBuilder::LoadVocabFromCsv(connectionDetails = cd, cdmSchema = cdmSchema, vocabFileLoc = vocabFileLoc)

print("==================== Running: LoadEventTables ====================")                                    
ETLSyntheaBuilder::LoadEventTables(connectionDetails = cd, cdmSchema = cdmSchema, syntheaSchema = syntheaSchema, cdmVersion = cdmVersion, syntheaVersion = syntheaVersion)

print("==================== Running: CreateOMOPonFHIRTables ====================")  
source("R/CreateOMOPonFHIRTables.r")
CreateOMOPonFHIRTables(connectionDetails = cd, cdmSchema = cdmSchema, resultsSchema = resultsSchema, vocabSchema = cdmSchema)

install.packages("remotes")
remotes::install_github("OHDSI/Achilles")


connectionDetails <- createConnectionDetails(dbms = "postgresql",
                                             server = synthea_db,
                                             user = "postgres",
                                             password = synthea_db_pass,
                                             port=synthea_db_port,
                                             pathToDriver="/drivers")
       
# HERE we could do something with the script found here:
# http://localhost:8080/WebAPI/ddl/results?dialect=postgresql&schema=results&vocabSchema=cdm_synthea&tempSchema=temp&initConceptHierarchy=true
# MVP: create an SQL file from that endpoint's response
# STEP 1: Load that file as a string 
# STEP 2: Use ODHSI/SQLRenderer to load the SQL onto the server 
# Step 3: Do the same for additional f_tables needed for OMOPonFHIR
# STRECH: Separate step 3 out into another init file for separation of concerns
# NOTE: Test all of this in the form of a separate R file and docker script; 
#   when working against pre-made tables, merge with this file 

library(Achilles)
print("==================== Running: Achilles ====================")  
achilles(connectionDetails = connectionDetails,
         cdmDatabaseSchema = "cdm_synthea",
         resultsDatabaseSchema = "results",
         cdmVersion = "5.4", 
         outputFolder = "output")