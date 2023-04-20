#!/bin/bash
# 用法参考有道搜索 [linux有用的fg命令]  
set -m
echo PYTHONUNBUFFERED=$PYTHONUNBUFFERED
echo PROJECT_ENV=$PROJECT_ENV
while true;do date;sleep 86400;date;echo "loop--";done &
/root/miniconda3/envs/sd_python310/bin/python launch.py --port 9965 --listen --xformers --medvram &
/usr/bin/supervisord -c /etc/supervisor.conf &
fg %1