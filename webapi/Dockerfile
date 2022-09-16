FROM tomcat:9-jdk8-temurin

ADD https://github.com/OHDSI/WebAPI/releases/download/v2.10.1/WebAPI.war /usr/local/tomcat/webapps/
COPY wait-for-postgres.sh /usr/local/tomcat/wait-for-postgres.sh

RUN apt-get update && apt-get install -y postgresql-client  

ENV WEBAPI_URL http://localhost:8080
ENV env webapi-postgresql
ENV security_enabled false
ENV security_origin *
ENV datasource_driverClassName org.postgresql.Driver
ENV datasource_url jdbc:postgresql://webapi-postgres:5432/OHDSI
ENV datasource.cdm.schema cdm
ENV datasource.ohdsi.schema ohdsi
ENV datasource_username ohdsi_admin_user
ENV datasource_password admin1
ENV spring.jpa.properties.hibernate.default_schema ohdsi
ENV spring.jpa.properties.hibernate.dialect org.hibernate.dialect.PostgreSQLDialect
ENV spring.batch.repository.tableprefix ohdsi.BATCH_
ENV flyway_datasource_driverClassName org.postgresql.Driver
ENV flyway_datasource_url jdbc:postgresql://webapi-postgres:5432/OHDSI
ENV flyway_schemas ohdsi
ENV flyway.placeholders.ohdsiSchema ohdsi
ENV flyway_datasource_username ohdsi_admin_user
ENV flyway_datasource_password admin1
ENV flyway.locations classpath:db/migration/postgresql