max_attempts=20 # 最多重试20次
ecs_version=null # 预设为null
i=1
while [ $i -le $max_attempts ]; do
    if [ -f /var/lib/cloud/instance/user-data.txt ]; then
        ecs_version=$(jq -r '.version' /var/lib/cloud/instance/user-data.txt)
        if [ "$ecs_version" = "null" ]; then
            echo "获取到 ecs_version 有值 $ecs_version";
            break
        fi
    fi
    echo "尝试 #$i: user-data.txt 不存在或未找到版本信息，正在重试...";
    sleep 5
    i=$((i+1))
done