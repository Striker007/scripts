#!/usr/bin/env sh
##
# get IP's which are in system
# but aren't used by nginx
#
FREE="0";
URL_3rd="http://consul.localhost/check.php?item=";
if [ -z "$1" ]; then
    ip_list=`ip add | grep inet | egrep -v 127.0\|10.1\|inet6 | cut -d'/' -f1 | cut -d' ' -f6`;
else
    ip_list="$1"
fi;

echo '--free ip list--';

if [ -d "/etc/nginx" ]; then
for next_ip in $ip_list; do
    is_ip_used=`grep -R $next_ip /etc/nginx | wc -l`;
    if [ "${is_ip_used}" -eq "${FREE}" ]; then

    # fork threads, for check ip in 3rd party service
    api_result=`curl -s $URL_3rd$next_ip\&type=json` &&
    check=`python - <<EOF
import json,sys
null=None
try:
    b=bool(json.loads(json.dumps($api_result['register'])))
    if False == b:
        i='free'
    else:
        i='blocked'
    print(i)
except:
    print('error')
    pass
EOF` && echo "$next_ip - $check"
    fi

done
fi
# wait for threads
wait

echo '---------';
