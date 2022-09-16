FROM alphora/cqf-ruler
COPY . .
# Install utilitizes for wget and tar
RUN apt-get update 
RUN apt-get install -y wget 
RUN apt-get install bzip2 
# Special directory for hapi cli scripts
RUN mkdir /hapi-cli  
# Pull the tar down
RUN wget https://github.com/hapifhir/hapi-fhir/releases/download/v6.1.1/hapi-fhir-6.1.1-cli.tar.bz2 
# Unzip the tar
RUN tar -xf hapi-fhir-6.1.1-cli.tar.bz2 --directory /hapi-cli
# Remove the tar file 
RUN rm hapi-fhir-6.1.1-cli.tar.bz2 
# Make sure the cli file is executable
RUN chmod a+x /hapi-cli/hapi-fhir-cli
# Make sure the PATH includes the hapi-cli directory
ENV PATH /hapi-cli:$PATH
CMD ["java", "-cp", "server/ROOT.war", "-Dloader.path=WEB-INF/classes,WEB-INF/lib,WEB-INF/lib-provided,plugin", "org.springframework.boot.loader.PropertiesLauncher"]