# docker-yp-prserv
yocto container running a PRSERV and a hash equivalence server

One branch per Yocto release, each with its own ports and its own volume:

| Branch | Source | prserv rw / ro | hashserv rw / ro | Volume (named) | Path in the container |
|---|---|---|---|---|---|
| `kirkstone` | poky kirkstone | 8181 / 8282 | 8383 / 8484 | `prhashserv-kirkstone` | `/home/yocto/pr_hash_serv-volume-kirkstone` |
| `scarthgap` | poky scarthgap | 8585 / 8686 | 8787 / 8888 | `prhashserv-scarthgap` | `/home/yocto/pr_hash_serv-volume-scarthgap` |
| `wrynose` (= `master`) | bitbake 2.18 | 9191 / 9292 | 9393 / 9494 | `prhashserv-wrynose` | `/home/yocto/pr_hash_serv-volume-wrynose` |

`./build-and-run.sh` builds the image and starts it with the named volume of the branch.

`master` follows `wrynose`. A setup that was built from the old `master` is a scarthgap setup: rebuild it from the
`scarthgap` branch (same ports, same path) and migrate its data as described below.

## Existing setups keep working
The path inside the container is the same as before, so a `docker run -v /some/host/dir:<path>` of an existing setup
still works unchanged. Uid/gid 2000 (`yocto`) are unchanged too, so existing data stays readable.

## Migrating data from a container started the old way
Before, `build-and-run.sh` used an anonymous volume. To move its data into the named volume:
```
docker stop <old-container>
./migrate-volume.sh <branch> <old-container>   # copy only, nothing is deleted
./build-and-run.sh
```
The script refuses to run while the old container is up (the sqlite files would be inconsistent; `FORCE=1`
overrides) and refuses to write into a volume that is not empty. Delete the old container and its volume yourself
once the new one works.

Client side (local.conf): `PRSERV_HOST = "host:<prserv rw port>"`, `BB_HASHSERVE = "host:<hashserv rw port>"`.
