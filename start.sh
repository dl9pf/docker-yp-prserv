#!/bin/bash
set -x

VOL=/home/yocto/pr_hash_serv-volume-wrynose
export PATH=/home/yocto/bitbake/bin:$PATH
rm -rf /tmp/PRServer*.pid || true

# rw prserv on port 9191
bitbake-prserv --start --file $VOL/prserv.db --loglevel=DEBUG --log $VOL/prserv-rw.log --port 9191
# ro prserv on port 9292
bitbake-prserv --start -r --file $VOL/prserv.db --loglevel=DEBUG --log $VOL/prserv-ro.log --port 9292
# rw hashserv on port 9393
bitbake-hashserv --bind :9393 --log DEBUG --database $VOL/hashserv.db > $VOL/hashserv-rw.log 2>&1 &
# ro hashserv on port 9494
bitbake-hashserv -r --bind :9494 --log DEBUG --database $VOL/hashserv.db > $VOL/hashserv-ro.log 2>&1 &

sleep 1

exit_script(){
echo 'cleanup prserv and hashserv'
pkill -f bitbake-prserv || true
pkill -f bitbake-hashserv || true
sleep 1
trap - SIGINT SIGTERM
kill -- -$$
}

trap exit_script SIGINT SIGTERM

# background + wait: bash runs the trap at once on SIGTERM (a foreground tail would delay it)
tail -f $VOL/*.log &
wait
