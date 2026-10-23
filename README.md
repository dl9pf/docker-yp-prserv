# docker-yp-prserv
yocto container running a PRSERV and a hash equivalence server

Branches: `scarthgap` (poky scarthgap, ports 8585-8888), `wrynose` (bitbake 2.18, ports 9191-9494).

| port (wrynose) | service | mode |
|---|---|---|
| 9191 | prserv | read-write |
| 9292 | prserv | read-only |
| 9393 | hashserv | read-write |
| 9494 | hashserv | read-only |

`./build-and-run.sh` builds and starts it; the databases live in the volume `prhashserv-wrynose`.
Client side (local.conf): `PRSERV_HOST = "host:9191"`, `BB_HASHSERVE = "host:9393"`.
