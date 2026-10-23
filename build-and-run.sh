#!/bin/bash
# Build the image and start the container with the named volume of this branch.
# If an older container of this setup (anonymous volume) is found, its data is copied into the named volume first.
#   ASSUME_YES=1 ./build-and-run.sh     do not ask before stopping the old container
#   DATA_VOLUME=/srv/prserv ./build-and-run.sh    use your own volume name or host directory instead
#   RW_BIND=10.0.0.5 RO_BIND=0.0.0.0 ./build-and-run.sh   publish the read-write ports (9191, 9393) only on this address
#                                  and the read-only ports (9292, 9494) on that one; default: all interfaces. The
#                                  read-write hashserv lets anonymous clients delete entries (@db-admin), keep it private.

set -e
set -x

BRANCH=wrynose
PORTS_RW="9191 9393"   # prserv rw, hashserv rw
PORTS_RO="9292 9494"   # prserv ro, hashserv ro
DATA="${DATA_VOLUME:-prhashserv-$BRANCH}"
path="/home/yocto/pr_hash_serv-volume-$BRANCH"
here="$(cd "$(dirname "$0")" && pwd)"
DATETAG=$(date +%Y-%m-%d)

# Newest container (running or not) with an anonymous or other named volume at $path.
find_old() {
  local id kind name
  for id in $(docker ps -a -q --filter "volume=$path"); do
    read -r kind name < <(docker inspect -f "{{range .Mounts}}{{if eq .Destination \"$path\"}}{{.Type}} {{.Name}}{{end}}{{end}}" "$id")
    if [ "$kind" = volume ] && [ "$name" != "$DATA" ]; then echo "$id"; return; fi
  done
}

# Containers of an earlier run of this script: they use $DATA (named volume or host directory) at $path.
find_current() {
  local id
  for id in $(docker ps -a -q --filter "volume=$path"); do
    if [ "$(docker inspect -f "{{range .Mounts}}{{if eq .Destination \"$path\"}}{{if .Name}}{{.Name}}{{else}}{{.Source}}{{end}}{{end}}{{end}}" "$id")" = "$DATA" ]; then echo "$id"; fi
  done
}

# Migrate only into a named volume that does not exist yet; a host directory (DATA_VOLUME=/...) is used as it is.
old=
if [[ "$DATA" != /* ]] && ! docker volume inspect "$DATA" >/dev/null 2>&1; then
  old="$(find_old)"
  if [ -n "$old" ]; then
    echo "Found an old container with data: $(docker inspect -f '{{.Name}} ({{.Config.Image}}), {{.State.Status}}' "$old")."
    echo "After the build its data is copied into the volume $DATA. A running old container is stopped, not removed."
    if [ -z "${ASSUME_YES:-}" ]; then
      if [ -t 0 ]; then read -r -p "Continue? [y/N] " ans; [ "$ans" = y ] || [ "$ans" = Y ] || { echo "aborted" >&2; exit 1; }
      else echo "not a terminal: set ASSUME_YES=1 to continue" >&2; exit 1; fi
    fi
  fi
fi

docker build --no-cache --network host --tag prhashserv:production-"$BRANCH"-"$DATETAG" .

if [ -n "$old" ]; then
  [ "$(docker inspect -f '{{.State.Status}}' "$old")" != running ] || docker stop -t 30 "$old"
  "$here/migrate-volume.sh" "$BRANCH" "$old"
fi

# Replace the container of an earlier run: it holds the ports. The data stays in $DATA.
for id in $(find_current); do
  [ "$(docker inspect -f '{{.State.Status}}' "$id")" != running ] || docker stop -t 30 "$id"
  docker rm "$id"
done

args=()
for p in $PORTS_RW; do args+=(-p "${RW_BIND:+$RW_BIND:}$p:$p"); done
for p in $PORTS_RO; do args+=(-p "${RO_BIND:+$RO_BIND:}$p:$p"); done
docker run "${args[@]}" -v "$DATA:$path" -d prhashserv:production-"$BRANCH"-"$DATETAG"
