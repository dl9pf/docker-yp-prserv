#!/bin/bash
set -x

cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/build
rm -rf /tmp/PRServer*.pid || true

bitbake-prserv --start --file /home/yocto/prserv/sqlite3.db --loglevel=DEBUG --log /home/yocto/prserv/prserv.log --port 8585

exit_script(){
echo 'cleanup prserv'
cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/build
bitbake-prserv --stop || true
sleep 1
trap - SIGINT SIGTERM
kill -- -$$
}

trap exit_script SIGINT SIGTERM

tail -f /home/yocto/prserv/prserv.log
