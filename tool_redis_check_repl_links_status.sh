#!/usr/bin/env bash
for i in $(ps ax | grep redis | grep -v grep | cut -d':' -f3);
    status=`redis-cli -p $i info | grep master_link`;
    if [[ -n $status ]]; then
        echo -n $i ' ';
        echo $status;
    else
        echo $i ' CRIT link down';
    fi
done
