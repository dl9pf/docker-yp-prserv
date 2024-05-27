#!/bin/bash
set -x

# prserv
cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/pr_hash_serv-volume-scarthgap/
pwd
rm -rf /tmp/PRServer*.pid || true
# rw prserv on port 8181
bitbake-prserv --start --file /home/yocto/pr_hash_serv-volume-scarthgap/prserv.db --loglevel=DEBUG --log /home/yocto/pr_hash_serv-volume-scarthgap/prserv-rw.log --port 8585
# ro prserv on port 8282
bitbake-prserv --start -r --file /home/yocto/pr_hash_serv-volume-scarthgap/prserv.db --loglevel=DEBUG --log /home/yocto/pr_hash_serv-volume-scarthgap/prserv-ro.log --port 8686
# rw hashserv on port 8383
bitbake-hashserv --bind :8787 --log DEBUG --database /home/yocto/pr_hash_serv-volume-scarthgap/hashserv.db > /home/yocto/pr_hash_serv-volume-scarthgap/hashserv-rw.log 2>&1 &
# ro hashserv on port 8484
bitbake-hashserv -r --bind :8888 --log DEBUG --database /home/yocto/pr_hash_serv-volume-scarthgap/hashserv.db > /home/yocto/pr_hash_serv-volume-scarthgap/hashserv-ro.log 2>&1 &

sleep 1

exit_script(){
echo 'cleanup prserv'
cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/pr_hash_serv-volume-scarthgap
bitbake-prserv --stop || true
killall bitbake-hashserv || true
sleep 1
trap - SIGINT SIGTERM
kill -- -$$
}

trap exit_script SIGINT SIGTERM

tail -f /home/yocto/pr_hash_serv-volume-scarthgap/*.log
