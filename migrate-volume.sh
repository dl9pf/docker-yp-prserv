#!/bin/bash
# Copy the data of an existing container into the named volume of its branch.
# Copy only: the old container and its volume are left untouched, delete them yourself once the new setup works.
#   ./migrate-volume.sh <kirkstone|scarthgap|wrynose> <old-container>
#   FORCE=1 ./migrate-volume.sh ...    copy although the old container still runs (sqlite may be inconsistent)
set -euo pipefail
branch="${1:?usage: $0 <kirkstone|scarthgap|wrynose> <old-container>}"
old="${2:?usage: $0 <kirkstone|scarthgap|wrynose> <old-container>}"
vol="prhashserv-$branch"
path="/home/yocto/pr_hash_serv-volume-$branch"

if [ "$(docker inspect -f '{{.State.Running}}' "$old")" = true ] && [ -z "${FORCE:-}" ]; then
  echo "stop $old first (docker stop $old) so the sqlite files are consistent, or set FORCE=1" >&2
  exit 1
fi
if docker volume inspect "$vol" >/dev/null 2>&1 \
   && [ -n "$(docker run --rm --network none -v "$vol:/new" debian:trixie-slim ls -A /new)" ]; then
  echo "volume $vol is not empty, refusing to overwrite it" >&2
  exit 1
fi
docker run --rm --network none --volumes-from "$old" -v "$vol:/new" debian:trixie-slim cp -a "$path/." /new/
echo "copied $path of $old to volume $vol"
