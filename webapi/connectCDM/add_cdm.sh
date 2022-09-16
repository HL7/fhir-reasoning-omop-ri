#!/usr/bin/env bash
set -e

WEBAPI_DB_PORT=54321
WEB_API_PORT=8080

# Get variables, make sure WEBAPI_DB_HOST and WebAPI_HOST are not empty.
read -p "WebAPI Database Host: " WEBAPI_DB_HOST; if [[ -z "$WEBAPI_DB_HOST" ]]; then printf '%s\n' "No input entered" && exit 1; fi
read -sp "WebAPI DB Pass [changeMe]: " WEBAPI_DB_PASS; WEBAPI_DB_PASS=${WEBAPI_DB_PASS:-changeMe}; echo ""
read -p "WebAPI Host [$WEBAPI_DB_HOST]: " WEBAPI_HOST; WEBAPI_HOST=${WEBAPI_DB_HOST:-$WEBAPI_DB_HOST}; echo ""

PGPASSWORD=$WEBAPI_DB_PASS psql -h $WEBAPI_DB_HOST -p $WEBAPI_DB_PORT -U postgres -f './cdm_config.sql' OHDSI

sleep 1

# Need to manually refresh webAPI so that it sees this
#curl "$WEBAPI_HOST:8080/WebAPI/source/refresh" - docker image doesnt have curl
wget -q "$WEBAPI_HOST:$WEB_API_PORT/WebAPI/source/refresh" -O /dev/null

>&2 echo "Added CDM to web api"

