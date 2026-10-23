# docker-yp-prserv
yocto container running a PRSERV and a hash equivalence server

One branch per Yocto release, each with its own ports and its own volume:

| Branch | Source | prserv rw / ro | hashserv rw / ro | Volume (named) | Path in the container |
|---|---|---|---|---|---|
| `kirkstone` | poky kirkstone | 8181 / 8282 | 8383 / 8484 | `prhashserv-kirkstone` | `/home/yocto/pr_hash_serv-volume-kirkstone` |
| `scarthgap` | poky scarthgap | 8585 / 8686 | 8787 / 8888 | `prhashserv-scarthgap` | `/home/yocto/pr_hash_serv-volume-scarthgap` |
| `wrynose` (= `master`) | bitbake 2.18 | 9191 / 9292 | 9393 / 9494 | `prhashserv-wrynose` | `/home/yocto/pr_hash_serv-volume-wrynose` |

`./build-and-run.sh` builds the image and starts it with the named volume of the branch.

## Existing setups keep working
The path inside the container is the same as before, so a `docker run -v /some/host/dir:<path>` of an existing setup
still works unchanged. Uid/gid 2000 (`yocto`) are unchanged too, so existing data stays readable.

## Migrating data from a container started the old way
Before, `build-and-run.sh` used an anonymous volume. `./build-and-run.sh` now finds such a container by itself (any
container, running or stopped, with a volume at the path above that is not the named volume) and, while the named
volume does not exist yet, does this:

1. asks once before touching anything (`ASSUME_YES=1` skips the question; without a terminal it refuses);
2. builds the new image;
3. stops the old container (it is not removed, so you can go back) and copies its data into the named volume with
   `migrate-volume.sh`;
4. starts the new container.

`./migrate-volume.sh <branch> <old-container>` does only the copy and can be run by hand. It never deletes anything,
refuses to run while the old container is up (the sqlite files would be inconsistent; `FORCE=1` overrides) and refuses
to write into a volume that is not empty. Delete the old container and its volume yourself once the new one works.

To keep using your own directory or volume, run `DATA_VOLUME=/srv/prserv ./build-and-run.sh`; no migration is done then.

Client side (local.conf): `PRSERV_HOST = "host:<prserv rw port>"`, `BB_HASHSERVE = "host:<hashserv rw port>"`.
