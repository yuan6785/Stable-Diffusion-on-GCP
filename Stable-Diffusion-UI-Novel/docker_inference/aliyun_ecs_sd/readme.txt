阿里云的sd部署流程以及相关脚本文件保存

搜索笔记 [stablediffusionwebui安装过程之阿里云dreambooth-新版本nas版本]

重要: 打镜像之前记得 
1. supervisorctl stop all
2. rm -rf /home/stable-diffusion-webui   /home/ComfyUI
3. rm -rf /var/lib/cloud/instance/user-data.txt   # 这个很重要，否则镜像里面有这个数据，ecs的创建挂载的用户数据会被镜像的覆盖



下面就是该笔记的大概内容---------------------------------------------------------------------------------------------

这里只有nas的部署流程，其他的请参考笔记 【stablediffusionwebui安装过程之阿里云dreambooth】
各种sd的源码修改，比如支持style等等的操作在:  /Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/bugs.txt

下面的所有脚本都保存在(最新文件一定要参考下面这个路径的项目脚本)-------重要--------
(保存在/Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_ecs_sd) 

用美东的sdwebui-aliynfunc-nas-debug镜像创建ecs，可以从“启动实例模板->sdwebui-aliynfunc-nas-debug 创建实例即可”
-----------------------
配置虚拟内存
安装包
apt update
apt install supervisor nginx
自启动
systemctl enable supervisor 
systemctl enable nginx
-------------------------

--------------------------
 写一个启动服务, 用于绑定nas盘和superver的启动命令-------这个必须写在ecs里面，其他命令可以通过mount到nas后，启动存在nas的命令，所以第一个命令非常重要，其他命令都可以随时修改，不用打镜像
/root/mount_nas.sh  # 记得chmod +x /root/mount_nas.sh 


挂载nas后的初始化命令
/mnt/sdwebui_public/ecs_versions/ecs_init.sh  # 记得chmod +x /mnt/sdwebui_public/ecs_versions/ecs_init.sh 


-------------------------
python的sd环境构建参考(这一步需要预先在nas或者公共云盘上面构建好)
fork_main分支
/Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo/Dockerfile.aliyun.libo.20230713
/Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo/Dockerfile.aliyun.libo.20231102  最近的版本--重要调试构建(下一次在这个基础上更新)---
或者
/Users/yuanxiao/workspace/0yxgithub/stable-diffusion-on-gcp-no-aliyun/Stable-Diffusion-UI-Agones/sd-webui-yx/Dockerfile.supervisor2
调试ecs:
/Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo/readme_debug.txt
--------------------------


--------------------------
 写一个启动服务, 用于启动sd (保存在/Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_ecs_sd)
/mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh  #记得 chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh
这个shell脚本用于版本分发, 主要服务构建在ecs_pre_start_xxxxxx.sh里面



------------ minio的启动命令(分发)----------
/mnt/sdwebui_public/ecs_versions/1_4_1/ecs_minio.sh  文件实例,  chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_minio.sh
这个shell脚本用于版本分发, 主要服务构建在ecs_minio_xxxxxx.sh里面
# 我测试是成功的----管理员playdayy  bbqbbq123  ; 普通用户: ecsuser   ecsuserqwe
# 策略文件和minio安装搜索 /Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo/readme_minio.txt // 这个是不分用户的----阿里云训练机版本
# 判断/home/stable-diffusion-webui/yx_end_rsync.txt这个文件是否存在，如果存在则开始执行下面的，不存在则等待1秒
# sd版本的:  .minio.sys文件夹保存在 /Users/yuanxiao/workspace/0yxgithub/stable-diffusion-on-gcp-no-aliyun/Stable-Diffusion-UI-Agones/sd-webui-yx/dockerdata/ecs141_minio.sys  
# comfyui版本的: .minio.sys文件夹保存在 /Users/yuanxiao/workspace/0yxgithub/stable-diffusion-on-gcp-no-aliyun/Stable-Diffusion-UI-Agones/sd-webui-yx/dockerdata/ecs141_minio_comfyui.sys  ---- 重要，解决了阿里云函数的层级混乱问题---



------------ loop任务的例子----------
/mnt/sdwebui_public/ecs_versions/1_4_1/ecs_looptask.sh  文件实例,  chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_looptask.sh
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20230713_train/bin/python -u  /mnt/sdwebui_public/ecs_versions/1_4_1/loop_py.py
------------



配置supervisor
supervisor.conf
ecs内部 vi /etc/supervisor/supervisord.conf