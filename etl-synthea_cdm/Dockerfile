FROM rocker/verse:4.1.2

RUN apt-get -y update && apt-get install -y \
   default-jdk \
   r-cran-rjava \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/

RUN install2.r --error \
    DatabaseConnector \
    devtools \
    readxl \
    dplyr \
    tidyr

# Get the  postgres JDBC driver and put it in /drivers
RUN mkdir /drivers && cd /drivers && \
    wget https://jdbc.postgresql.org/download/postgresql-42.3.1.jar

# Add our script
COPY a.R /a.R
# Add our additional scripts and files 
COPY ./R/CreateOMOPonFHIRTables.r /R/CreateOMOPonFHIRTables.r
COPY ./additional_sql /additional_sql


# Make directory so that we can debug the output
RUN mkdir /output_logs

CMD ["/bin/bash", "-c", "Rscript a.R 2>&1 | tee /output_logs/synthea_db_generator.log"]
