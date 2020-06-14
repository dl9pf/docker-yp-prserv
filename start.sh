#!/bin/bash
set -x

# prserv
cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/prserv-volume/
pwd
rm -rf /tmp/PRServer*.pid || true
bitbake-prserv --start --file /home/yocto/prserv-volume/prserv.db --loglevel=DEBUG --log /home/yocto/prserv-volume/prserv.log --port 8585
bitbake-hashserv --bind :8686 --log DEBUG --database /home/yocto/prserv-volume/hashserv.db > /home/yocto/prserv-volume/hashserv.log 2>&1 &
sleep 1

exit_script(){
echo 'cleanup prserv'
cd /home/yocto/poky
source ./oe-init-build-env /home/yocto/prserv-volume
bitbake-prserv --stop || true
killall bitbake-hashserv || true
sleep 1
trap - SIGINT SIGTERM
kill -- -$$
}

trap exit_script SIGINT SIGTERM

tail -f /home/yocto/prserv-volume/*.log
