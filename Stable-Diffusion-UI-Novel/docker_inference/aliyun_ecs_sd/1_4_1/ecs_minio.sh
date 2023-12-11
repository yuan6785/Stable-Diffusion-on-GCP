# 版本控制脚本，启动sd还是minio的版本
echo ---------outter start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
sleep 10
echo ---------outter version control-------$(date +"%Y-%m-%d %H:%M:%S")-------------
max_attempts=20 # 最多重试20次
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
# bash /mnt/sdwebui_public/ecs_versions/1_4_1/${ecs_version}
# 判断ecs_version里面是否包含comfyui，如果包含则启动minio，否则启动sd
if [[ $ecs_version =~ "comfyui" ]]; then
    echo "启动comfyui的minio"
    bash /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_minio_comfyui.sh
else
    echo "启动sd的minio"
    bash /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_minio_sd.sh
fi
