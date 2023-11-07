#!bin/bash
# 写一个启动服务, 用于绑定nas盘和superver的启动命令-------这个必须写在ecs里面，其他命令可以通过mount到nas后，启动存在nas的命令，所以第一个命令非常重要，其他命令都可以随时修改，不用打镜像
/root/mount_nas.sh  # 记得chmod +x /root/mount_nas.sh 
# 挂载nas盘---脚本生成ecs的时候，会第一次挂载； 后面重启机器，重启supervisor都是已经挂载的状态
echo ---------start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo "mount nas start"
if ! mountpoint -q /mnt;then mount -t nfs -o vers=3,noacl,nolock,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 1386f52d-h9fi.us-east-1.extreme.nas.aliyuncs.com:/share /mnt;fi
echo "mount nas end"
while [ ! -f "/mnt/sdwebui_public/ecs_versions/ecs_init.sh" ]; do sleep 1; done
echo "ecs init start"
chmod +x /mnt/sdwebui_public/ecs_versions/ecs_init.sh;
. /mnt/sdwebui_public/ecs_versions/ecs_init.sh;
echo "ecs init end"
while true;do date;sleep 86400;echo "loop--";done