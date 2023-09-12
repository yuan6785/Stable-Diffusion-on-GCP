#!/bin/bash
# 用法参考有道搜索 [linux有用的fg命令]  ---- 阿里云函数不支持sh命令，可以用cmd一条命令即可
# /usr/sbin/nginx -c /etc/nginx/nginx.conf -g 'daemon off;
set -m
echo PYTHONUNBUFFERED=$PYTHONUNBUFFERED
echo PROJECT_ENV=$PROJECT_ENV
while true;do date;sleep 86400;date;echo "loop--";done &
echo "yx test 1111">/var/log/sdwebui.log &
/usr/bin/supervisord -c /etc/supervisord.conf &
/usr/sbin/nginx -c /etc/nginx/nginx.conf &
sleep 30 && tail -f /var/log/sdwebui.log &
fg %1