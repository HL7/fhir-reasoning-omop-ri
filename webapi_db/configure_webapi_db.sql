CREATE ROLE ohdsi_admin
  CREATEDB REPLICATION
   VALID UNTIL 'infinity';
COMMENT ON ROLE ohdsi_admin
  IS 'Administration group for OHDSI applications';


CREATE ROLE ohdsi_app
   VALID UNTIL 'infinity';
COMMENT ON ROLE ohdsi_app
  IS 'Application groupfor OHDSI applications';


CREATE ROLE ohdsi_admin_user LOGIN ENCRYPTED PASSWORD 'md58d34c863380040dd6e1795bd088ff4a9'
   VALID UNTIL 'infinity';
GRANT ohdsi_admin TO ohdsi_admin_user;
COMMENT ON ROLE ohdsi_admin_user
  IS 'Admin user account for OHDSI applications';


CREATE ROLE ohdsi_app_user LOGIN ENCRYPTED PASSWORD 'md55cc9d81d14edce93a4630b7c885c6410'
   VALID UNTIL 'infinity';
GRANT ohdsi_app TO ohdsi_app_user;
COMMENT ON ROLE ohdsi_app_user
  IS 'Application user account for OHDSI applications';


CREATE DATABASE "OHDSI"
  WITH ENCODING='UTF8'
       OWNER=ohdsi_admin
       CONNECTION LIMIT=-1;
COMMENT ON DATABASE "OHDSI"
  IS 'OHDSI database';
GRANT ALL ON DATABASE "OHDSI" TO GROUP ohdsi_admin;
GRANT CONNECT, TEMPORARY ON DATABASE "OHDSI" TO GROUP ohdsi_app;


CREATE SCHEMA webapi
       AUTHORIZATION ohdsi_admin;
COMMENT ON SCHEMA webapi
  IS 'Schema containing tables to support WebAPI functionality';
GRANT USAGE ON SCHEMA webapi TO PUBLIC;
GRANT ALL ON SCHEMA webapi TO GROUP ohdsi_admin;
GRANT USAGE ON SCHEMA webapi TO GROUP ohdsi_app;


ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLES
    TO ohdsi_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT SELECT, USAGE ON SEQUENCES
    TO ohdsi_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT EXECUTE ON FUNCTIONS
    TO ohdsi_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT USAGE ON TYPES
    TO ohdsi_app;
