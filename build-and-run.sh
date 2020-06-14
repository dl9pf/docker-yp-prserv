#!/bin/bash

DATETAG=$(date +%Y-%m-%d)
docker build --tag prserv:production-$DATETAG .
docker run -p 8585:8585 -p 8686:8686  -d prserv:production-$DATETAG
