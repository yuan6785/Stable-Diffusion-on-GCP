登录挂载nfs的ubuntu的ec2， ubuntu22.04. 不需要gpu(如果想要完全测试，就买含gpu的ec2即可)，只是用来编译python环境
----
apt-get install nvidia-driver-460  # 安装显卡驱动
nvidia-smi # 查看显卡驱动是否安装成功
按照Dockerfile.aliyun.libo的内容一步步按照python环境。python路径可以更改为/mnt的nfs路径
例如: /mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python
---
我的调试镜像打包好的:  sdwebui-aliynfunc-nas-debug（含GPU的）。
实例启动模板: sdwebui-aliynfunc-nas-debug （用上面的镜像和相关机型的，直接用即可）
如果内存不够: 最好创建一个虚拟内存----todo
---
也可以直接在云函数中"登录实例"--进入docker镜像中， 进行调试
---调试rsync--
rsync -azP --no-perms --no-owner --no-group --exclude '/models' --exclude '/embeddings' --exclude '/scripts' --exclude '/samples' --exclude '/localizations' --exclude '/outputs'  /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/ /home/stable-diffusion-webui   




最后验证按照的命令--(如果用的非gpu机器启动的， 这里不要用gpu启动，只是验证---)
cd /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram --skip-torch-cuda-test
如果是非gpu的ec2，这个命令会耗尽内存，关闭窗口即可结束程序


带gpu的ec2的启动命令--
cd /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui&&/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram 





----本地打包镜像
cd /Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo
# docker build -t sand:1.0 -f Dockerfile.finally.libo.supervisor  .  # 本地打包镜像--supervisor版本--有问题，启动不起来
docker build -t sand:1.0 -f Dockerfile.finally.libo  .  # 只有sd的版本
---进入容器调试
docker run -it --rm sand:1.0 /bin/bash
----推送本地镜像到阿里云（记得修改版本号）
docker login --username=yuanxiao@playnexx registry-intl.us-east-1.aliyuncs.com  # b*****1**
docker tag sand:1.0 registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:v31
docker push registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:v31
----清理镜像
docker images
docker rmi -f sand:1.0
docker image prune -a  # 清理没有容器生成的所有镜像的存储空间







