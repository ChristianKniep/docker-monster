#!/bin/bash

ETCD_HOST=HOSTNAME
if [[ ! ${ETCD_HOST} =~ [0-9]+ ]];then
    echo "ETCD_HOST ${ETCD_HOST} should match [0-9]+"
    exit 1
fi
BINARY=/usr/bin/etcd
trap stop SIGTERM

function wait_proc {
    if [ $(ps -ef|grep -v grep|grep -c ${BINARY}) -ne 0 ];then
        sleep 1
        wait_proc
    fi
}

cd /var/lib/etcd/
/usr/bin/etcd -c ${ETCD_HOST}:4001 -s ${ETCD_HOST}:7001 &
MYPID=$(ps -ef|grep -v grep |grep ${BINARY}|awk '{print $2}')

function stop () {
  kill -9 ${MYPID}
}

wait_proc
