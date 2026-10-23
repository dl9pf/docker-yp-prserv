#!/bin/bash

set -e
set -x

DATETAG=$(date +%Y-%m-%d)
docker build --no-cache --network host --tag prhashserv:production-wrynose-"$DATETAG" .
docker run -p 9191:9191 -p 9292:9292 -p 9393:9393 -p 9494:9494 \
  -v prhashserv-wrynose:/home/yocto/pr_hash_serv-volume-wrynose \
  -d prhashserv:production-wrynose-"$DATETAG"
