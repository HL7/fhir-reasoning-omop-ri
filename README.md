# FHIR-OMOP Development Sandbox

A unified development environment for digital quality measure evaluations. Some of the features supported by this repo include:

- Translating [Synthea](https://github.com/synthetichealth/synthea) patients into the [OMOP common data model](https://www.ohdsi.org/data-standardization/the-common-data-model/) using the [ETL-Synthea tool](https://github.com/OHDSI/ETL-Synthea)
- Leverage [FHIR's clinical quality module](http://hl7.org/fhir/clinicalreasoning-module.html) using [CQF Ruler](https://github.com/DBCG/cqf-ruler)
- Using the [HAPI FHIR CLI](https://hapifhir.io/hapi-fhir/docs/tools/hapi_fhir_cli.html) to populate FHIR servers with vocabularies, patients, and more.
- View CDM patient cohorts using the [Atlas UI](https://www.ohdsi.org/atlas-a-unified-interface-for-the-ohdsi-tools/)
- Interact with the CDM database through a FHIR server using [OMOPonFHIR](https://github.com/omoponfhir/omoponfhir-site-n-docs/wiki/Deployment-with-Docker), based on the Docker image [here](https://hub.docker.com/repository/docker/dphelan/omoponfhir-r4-v5.4)

Before you get started, you will need the following: 

- An [Athena Account](https://athena.ohdsi.org/search-terms/start) for downloading relevant vocabularies;
- A [UMLS Account](https://uts.nlm.nih.gov/uts/) and access to your [API Key](https://uts.nlm.nih.gov/uts/edit-profile), for expanding CPT vocabularies;
- [Docker](https://www.docker.com/) and ideally [Docker Desktop](https://www.docker.com/products/docker-desktop/), with frankly as many resources allocated to them as you can afford (we have run it with 6 cpus and 16GB of RAM)
- A few hours of time, as many of the scripts dependent on vocabularies take very long to run.

## Awkward Step 0: Include CQF-Ruler vocabularies before all else

Because hapi-fhir-cli, the utility we use to load vocabularies onto CQF[-ruler, defaults large-file uploads to a file system upload instead of an HTTP upload,](https://github.com/hapifhir/hapi-fhir/blob/master/hapi-fhir-cli/hapi-fhir-cli-api/src/main/java/ca/uhn/fhir/cli/UploadTerminologyCommand.java#L239) the vocabularies needed by CQF-Ruler need to be included in that directory before it's docker image is created. To do so, 

- Download necessary vocabularies (e.g. LOINC, SNOMED-CT, ICD-10, etc.)
- Create a subdirectory within `cqf-ruler` named `vocabulary`
- Copy the vocabulary files into the newly created `vocabulary` directory.

> NOTE: Due to changes in the file structure within LOINC version 2.7.3, that vocabulary is incompatible with the most recent version of the HAPI FHIR CLI at the time of this writing (HAPI FHIR CLI version `6.1.0`). The following changes to the LOINC vocabulary distribution should be made to load the LOINC vocabulary to CQF-Ruler:
>
> - Decompress the LOINC zip file. Rename the `AccessoryFiles/ComponentHierarchyBySystem` directory to `AccessoryFiles/MultiAxialHierarchy`
> - Rename the files found in that directory to `MultiAxialHierarchy.csv` and `MultiAxialHierarchyReadMe.txt`.
> - Recompress the LOINC vocabulary file.

## Step 1: Standing up digital quality measure infrastructure

We use docker compose to set up multiple pieces of infrastructure

```bash
docker compose build
docker compose up
```

This spins up containers for:

- A Postgres database for Synthea patient CDM data
- A Postgres database for OHDSI's WebAPI
- CQF Ruler
- OMOPonFHIR, connected to the Synthea CDM database
- OHDSI WebAPI, connected to the OHDSI's WebAPI Postgres DB
- OHDSI Atlas UI's, connected to the OHDSI's WebAPI

Wait a few minutes for everything to come up, then you can access the services:

- Atlas @ http://localhost/atlas/#/home
- CQF Ruler FHIR Server @ http://localhost:8081
- WebAPI @ http://localhost:8080
- OMOPonFHIR Server @ http://localhost:8082/omoponfhir4/
- Postgres database for Synthea data localhost:54320
    - Username: postgres
    - Password: changeMe *(Unless changed in `docker-compose.yml`)*
- Postgres database for WebAPI localhost:54321
    - Username: postgres
    - Password: changeMe *(Unless changed in `docker-compose.yml`)*

In the next few steps, we will initialize these various services and their endpoints with vocabularies, sample patient data, patient data cohorts, and more.

## Step 2: Populating the OMOP CDM using pre-generated Synthea data

Use these steps if you do not have a OMOP CDM already and would like to use pre-existing [Synthea](https://github.com/synthetichealth/synthea) CSV data via [ETL-Synthea](https://github.com/OHDSI/ETL-Synthea) to create an OMOP [CDM](https://github.com/OHDSI/CommonDataModel) v5.4 Postgres database. 

1. First you will need to download 5.x vocabularies from athena.ohdsi.org and make some minor changes to get the vocabulary ready for use. (_This is not included as it would be too big for git.)_
   1. Create an account → Click Download →DOWNLOAD VOCABULARIES → Download
   2. Once this is downloaded, extract the folder and place it in `etl-synthea_cdm` with a name of `vocabulary` (i.e `etl-synthea_cdm/vocabulary`)
   3. Run the CPT expansion script using your UMLS API key; navigate to the directory you extracted the vocabulary files into if you are not there already and run `./cpt.sh <YOUR API KEY>` where YOUR API_KEY is the API Key provided by the UMLS profile page. Windows users may execute instead `cpt.bat <YOUR_API_KEY>`. If you encounter a permissions issue in Linux environments, first use the command "chmod +x./cpt.sh" to give the file execution privileges. Please be aware this process may take a while.
   4. One last note: We encountered errors while running the Synthea-ETL tool pertaining to null values in the `CONCEPT.csv` file, related to an [existing GitHub issue](https://github.com/OHDSI/ETL-Synthea/issues/125), when running the Synthea ETL with Athena concepts. We recommend you run the following to avoid this, unless are getting your vocabularies from another source: 

      ```bash
      npm install -g fs
      node cleanAthenaVocab.js
      ```

      This script will clean entries in the `CONCEPT.csv` file that can be misinterpreted as NULL by the R interpreter.

2. Move the Synthea CSV patients of interest into the folder `etl-synthea_cdm/synthea`
   1. Alternatively, you can change the `COPY synthea /synthea` line in the Dockerfile to copy data over from any other source location on your machine. 

3. Run the script - After it completes you should have a OMOP CDM v5.4 database with data consisting of a population corresponding to the number of patients you start with. [Achilles](https://github.com/OHDSI/Achilles) was also run on this data. **This may take a long time >1hr** 

```bash
cd cdm/etl-synthea_cdm
docker compose build
docker compose up
```

4. You should now be able to access this database if need be
   - Synthea OMOP CDM Database: localhost:54320
     - Username: postgres
     - Password: clipper _(Unless changed in `etl-synthea_cdm/a.R`)_
   - To confirm this data was successfully uploaded onto your Postgres instance, you can connect to your docker instance via docker desktop's CLI or the `docker exec -it` command and print all the data stored under the person schema on the OHDSI-CDM_V54 database, by running the following:
     ```bash
     $ psql -U postgres
     $ \c OHDSI-CDM_V54
     $ SELECT * from cdm_synthea.person;
     ```

## Step 2b OPTIONAL: Create an OMOP CDM of simulated data using Synthea

If you want to generate new patients each time you set up the OMOP CDM, and not use your own preloaded patients, just change the `etl-synthea_cdm/create_db.sh` script to build the second docker image from `Dockerfile-with-generation`, instead of from `Dockerfile`

## Step 3: Add your OMOP CDM database to Atlas

There are helper scripts to facilitate adding a OMOP CDM Database to the WebAPI so that it shows up in Atlas in `webapi/connectCDM/`. If you have the `psql` command installed on your local machine you can use `add_cdm.sh` directly. Otherwise if you have docker follow the docker instructions below:

1. First you need to modify `webapi/connectCDM/cdm_config.sql`
   1. **source_connection** should be `jdbc:postgresql://<YOUR_PUBLIC_IP>:<CDM_DB_PORT>/<DATABASE>?user=<USER>&password=<PASSWORD>`
      - If you created a Synthea OMOP CDM database then
        - DATABASE is `OHDSI-CDM_V54`
        - CDM_DB_PORT is `54320`
        - USER is `postgres`
        - PASSWORD is `clipper`
      - Ex) `jdbc:postgresql://<YOUR_PUBLIC_IP>:5430/OHDSI-CDM_V54?user=postgres&password=password`
   2. **source_name** can be any name you want to reference this database (make unique)
   3. **source_key** this needs to be unique. The following queries use this key as a reference.
2. You can now run the helper script to connect to the WebAPI database and add you OMOP CDM database. The script will ask you for the WebAPI Database Host, WebAPI DB Pass and WebAPI Host. The Hosts should be <YOUR_PUBLIC_IP>. The password has a default value of `changeMe` and should be that unless you changed the `POSTGRES_PASSWORD` environment variable in `docker-compose.yml`. The ports for the WebAPI Database and WebAPI are hardcoded in the script as 54321 and 8080 respectively. These should not have to be changed unless you changed these in the `docker-compose.yml`.

```bash
cd webapi/connectCDM
./docker_add_cdm.sh
```

3. You should now be able to reload the Atlas page and see you CDM was added in the Configuration tab. _Note make sure you can see your data, **the add_cdm.sh script will not fail if you put the wrong information in for your CDM**._
4. If for whatever reason you need to remove your CDM from Atlas there is a `webapi/removeCDM/` directory with scripts similar to add. Just replace the `souce_key` in both of the two spots and run `docker_rm_cdm.sh`

## Step 4: Populate WebAPI database with default cohort definitions
To load default cohort definitions (we provide those from the [OHDSI Phenotype Library](https://github.com/OHDSI/PhenotypeLibrary)) into the Atlas WebAPI, we have created a dockerized node script. The following steps will upload those cohort definitions to the WebAPI. :

1. From the base directory,  `cd webapi/cohort-initialize/` 
2. Build the docker compose file using `docker compose build` 
3. Run the population script with `docker compose up`. 
4. After execution finishes, navigate to  http://localhost/atlas/#/home/ and click on Cohort Definitions in the sidebar to confirm that cohorts have been added.

## Step 5: Populate CQF-Ruler with vocabularies

CQF-Ruler can be loaded with vocabularies using the [HAPI FHIR CLI](https://hapifhir.io/hapi-fhir/docs/tools/hapi_fhir_cli.html) using the following steps. Refer to the HAPI FHIR CLI instructions on 

1. As part of Step 0, you should have downloaded the necessary vocabularies to an appropriate subdirectory under `cqf-ruler`.

2. After starting the CQF-Ruler server, enter into the Docker container by running `docker exec -it <container-id> bin/bash` from the terminal.

3. Upload vocabularies using the HAPI FHIR CLI `upload-terminology` flag (e.g. `hapi-fhir-cli upload-terminology -d vocabulary/<loinc-file-name>.zip -v r4 -t http://localhost:8080/fhir -u http://loinc.org`).

4. After the CLI upload is done, the DB will take a significant amount of time to actually complete that transaction. Watch the logs for the CQF-ruler container to see how that is moving along. 

## Step 6: Populating CQF-Ruler with Synthea patients

Use these steps to upload FHIR patient bundles generated from Synthea into CQF-Ruler.

1. Move the folder containing FHIR records exported by Synthea (this is typically `output/fhir` of whatever directory Synthea was executed from) to the base of the `cqf-ruler` directory. Take note of this directory name, as you will use it later in a bash script. We recommend using the name `synthea`, so as to be ignored by our `.gitignore`. 
2. Navigate to the `cqf-ruler` directory from the terminal.
3. Run the following command in order to register the CQF-ruler FHIR server with the `fhir` bash script:

```bash
bash fhir-uploader upload -s localhost:8081/fhir
```

4. Identify the Practitioner FHIR bundle to upload before all other bundles.
   1. If we don't first upload the practitioner information, the CQF server will reject all patients we try to upload on account of invalid references. 
   2. Determine the file name of the Practitioner FHIR Bundle in the Synthea output folder. This will take the form of a single JSON file with the pattern `practitionerInformation<uniqueID>.json`

5. Run the following command to upload FHIR practitioners to CQF-Ruler, selecting the appropriate base url (should be `localhost:8081/fhir`) when prompted; you should type `0` when prompted if you've followed these instructions verbatim:

```bash
  bash fhir-uploader upload <syntheaOutputDirectoryName>/<practitionerInformationFileName>
```

6. Run the following command to upload  FHIR patients to CQF-Ruler, selecting the appropriate base url (should be `localhost:8081/fhir`) when prompted; you should type `0` when prompted if you've followed these instructions verbatim:

```bash
  bash fhir-uploader upload -r <syntheaOutputDirectoryName>
```

7. To confirm that your bundles were uploaded correctly, use the browser-based GUI at `localhost:8081` or make a request to the CQF-ruler's FHIR server directly, at `localhost:8081/fhir`, using Postman/another HTTP request tool.

# Miscellaneous Notes: 

- If the CDM schema names are changed, you may need to update some of the SQL files used in `CreateOMOPonFHIRTables.r`, specifically the SQL in `results.sql` 