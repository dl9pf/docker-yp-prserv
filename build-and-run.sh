#!/bin/bash

DATETAG=$(date +%Y-%m-%d)
docker build --tag prhashserv:production-$DATETAG .
docker run -p 8181:8181 -p 8282:8282 -p 8383:8383 -p 8484:8484  -d prhashserv:production-$DATETAG
