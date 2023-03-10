#!/bin/bash
set -x

# prserv
cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/pr_hash_serv-volume/
pwd
rm -rf /tmp/PRServer*.pid || true
# rw prserv on port 8181
bitbake-prserv --start --file /home/yocto/pr_hash_serv-volume/prserv.db --loglevel=DEBUG --log /home/yocto/pr_hash_serv-volume/prserv-rw.log --port 8181
# ro prserv on port 8282
bitbake-prserv --start -r --file /home/yocto/pr_hash_serv-volume/prserv.db --loglevel=DEBUG --log /home/yocto/pr_hash_serv-volume/prserv-ro.log --port 8282
# rw hashserv on port 8383
bitbake-hashserv --bind :8383 --log DEBUG --database /home/yocto/pr_hash_serv-volume/hashserv.db > /home/yocto/pr_hash_serv-volume/hashserv-rw.log 2>&1 &
# ro hashserv on port 8484
bitbake-hashserv -r --bind :8484 --log DEBUG --database /home/yocto/pr_hash_serv-volume/hashserv.db > /home/yocto/pr_hash_serv-volume/hashserv-ro.log 2>&1 &

sleep 1

exit_script(){
echo 'cleanup prserv'
cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/pr_hash_serv-volume
bitbake-prserv --stop || true
killall bitbake-hashserv || true
sleep 1
trap - SIGINT SIGTERM
kill -- -$$
}

trap exit_script SIGINT SIGTERM

tail -f /home/yocto/pr_hash_serv-volume/*.log
