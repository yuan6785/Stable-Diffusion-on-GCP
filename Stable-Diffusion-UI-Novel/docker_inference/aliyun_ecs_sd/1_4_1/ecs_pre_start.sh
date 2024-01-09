#!/bin/bash
# /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh  #记得 chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh
echo ---------outter start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
sleep 10
echo ---------outter install jq-------$(date +"%Y-%m-%d %H:%M:%S")---------------
# if which jq &> /dev/null; 
#     then echo "jq 已经安装"; 
# else 
#     echo "jq 未安装，正在安装..."; 
#     apt install -y jq; 
# fi
# 将上面的if语句改为while
while ! which jq &> /dev/null;
do
    echo "jq 未安装，正在安装..."; 
    # DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends jq;  # 防止出现Package configuration的界面
    DEBIAN_FRONTEND=noninteractive apt install -y jq; 
    sleep 1;
done
echo "jq 已经安装"; 
echo ---------outter get user data-------$(date +"%Y-%m-%d %H:%M:%S")-------------
# # while判断/var/lib/cloud/instance/user-data.txt文件是否存在和有值
# while [ ! -f /var/lib/cloud/instance/user-data.txt ];
# do
#     echo "user-data.txt 不存在，正在获取..."; 
#     sleep 1;
# done
# echo "user-data.txt 已经存在";
# # while判断/var/lib/cloud/instance/user-data.txt文件是否存在和判断echo $(jq -r '.name' /var/lib/cloud/instance/user-data.txt)有值
# while true; do
#     output=$(jq -r '.a' /var/lib/cloud/instance/user-data.txt)
#     if [ "$output" != "null" ]; then
#         echo "$output"
#         break
#     fi
#     echo "user-data.txt 无值，正在获取...";
#     sleep 5  # 等待一秒钟再次检查
# done
# echo "user-data.txt 有值";
echo "不判断user-data.txt..."
echo ---------outter memory limit-------$(date +"%Y-%m-%d %H:%M:%S")-------------
# 获取本机内存大小
all_memory=$(free -m | awk '/Mem/ {print $2}')
ecs_limit_memory=$((all_memory * 1024 * 9 / 10)) # 限制内存为本机内存的90%
# 当all_memory大于60000,即60G时候，进行内存限制干预，也这个必定是sdxl
if [ $all_memory -gt 60000 ]; then
    # ulimit -v $ecs_limit_memory  # 暂时不限制内存
    # ulimit -v $ecs_limit_memory
    echo "内存限制为 $ecs_limit_memory"
else
    echo "内存不限制"
fi
echo ---------outter version control-------$(date +"%Y-%m-%d %H:%M:%S")-------------
max_attempts=10 # 最多重试10次
ecs_version=null # 预设为null
for (( i=1; i<=max_attempts; i++ )); do
    if [ -f /var/lib/cloud/instance/user-data.txt ]; then
        ecs_version=$(jq -r '.version' /var/lib/cloud/instance/user-data.txt)
        if [ "$ecs_version" != "null" ]; then
            echo "获取到 ecs_version 有值 $ecs_version";
            break
        fi
    fi
    echo "尝试 #$i: user-data.txt 不存在或未找到版本信息，正在重试...";
    sleep 5
done
# 判断ecs_version是否为null，如果是设置一个默认值---防止ecs没有用脚本启动，用的镜像启动，则没有user_data数据---
if [ "$ecs_version" == "null" ]; then
    # ecs_version="ecs_pre_start_20230713.sh"
    ecs_version="ecs_pre_start_20231102.sh"
fi
echo "操作完成，ecs_version 值为: $ecs_version"
echo ---------outter run real server-------$(date +"%Y-%m-%d %H:%M:%S")-------------
bash /mnt/sdwebui_public/ecs_versions/1_4_1/${ecs_version}

