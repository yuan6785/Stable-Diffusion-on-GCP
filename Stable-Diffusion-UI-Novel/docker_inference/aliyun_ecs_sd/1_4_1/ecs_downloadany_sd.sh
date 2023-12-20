#!/bin/bash
#启动离线下载的sd版本
echo ---------inner  start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
cd /home/stable-diffusion-webui
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/py3.10_other_test/bin/python -u /mnt/sdwebui_public/ecs_versions/1_4_1/download_any.py