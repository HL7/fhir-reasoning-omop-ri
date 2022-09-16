\connect "OHDSI";

-- NOTE: This script is run from inside the networked webapi db and therefore should use the docker network container name and port for the synthea cdm
INSERT INTO ohdsi.source (source_id, source_name, source_key, source_connection, source_dialect) 
SELECT nextval('ohdsi.source_sequence'), 'My Cdm', 'MY_CDM', 'jdbc:postgresql://cdm_postgres:5432/OHDSI-CDM_V54?user=postgres&password=clipper', 'postgresql';

-- CDM
INSERT INTO ohdsi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('ohdsi.source_daimon_sequence'), source_id, 0, 'cdm_synthea', 0
FROM ohdsi.source
WHERE source_key = 'MY_CDM'
;

-- VOCAB  cdm_synthea.vocabulary
INSERT INTO ohdsi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('ohdsi.source_daimon_sequence'), source_id, 1, 'cdm_synthea', 1
FROM ohdsi.source
WHERE source_key = 'MY_CDM'
;


-- RESULTS... You need to run Achilles to get the results table
INSERT INTO ohdsi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('ohdsi.source_daimon_sequence'), source_id, 2, 'results', 1
FROM ohdsi.source
WHERE source_key = 'MY_CDM'
;


-- -- TEMP
-- INSERT INTO ohdsi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
-- SELECT nextval('ohdsi.source_daimon_sequence'), source_id, 5, 'temp', 0
-- FROM ohdsi.source
-- WHERE source_key = 'MY_CDM'
-- ;