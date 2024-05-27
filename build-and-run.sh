#!/bin/bash

set -e
set -x

DATETAG=$(date +%Y-%m-%d)
docker build --no-cache --network host --tag prhashserv:production-scarthgap-$DATETAG .
docker run -p 8585:8585 -p 8686:8686 -p 8787:8787 -p 8888:8888  -d prhashserv:production-scarthgap-$DATETAG
