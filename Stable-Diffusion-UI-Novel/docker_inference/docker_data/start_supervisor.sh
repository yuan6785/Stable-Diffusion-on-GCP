#!/bin/bash
# 用法参考有道搜索 [linux有用的fg命令]  
set -m
echo PYTHONUNBUFFERED=$PYTHONUNBUFFERED
echo PROJECT_ENV=$PROJECT_ENV
while true;do date;sleep 86400;date;echo "loop--";done &
/usr/bin/supervisord -c /etc/supervisord.conf &
sleep 30 && tail -f /var/log/loopscript.log &
sleep 30 && tail -f /var/log/sdwebui.log &
fg %1