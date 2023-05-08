登录挂载nfs的ubuntu的ec2， ubuntu22.04. 不需要gpu(如果想要完全测试，就买含gpu的ec2即可)，只是用来编译python环境
----
apt-get install nvidia-driver-460  # 安装显卡驱动
nvidia-smi # 查看显卡驱动是否安装成功
按照Dockerfile.aliyun.libo的内容一步步按照python环境。python路径可以更改为/mnt的nfs路径
例如: /mnt/sdwebui_env/miniconda3/envs/sd_python310/bin/python
---
我的调试镜像打包好的:  sdwebui-aliynfunc-nas-debug（含GPU的）。
实例启动模板: sdwebui-aliynfunc-nas-debug （用上面的镜像和相关机型的，直接用即可）







最后验证按照的命令--(如果用的非gpu机器启动的， 这里不要用gpu启动，只是验证---)
cd /mnt/sdwebui_env/stable-diffusion-webui
/mnt/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram --skip-torch-cuda-test
如果是非gpu的ec2，这个命令会耗尽内存，关闭窗口即可结束程序


带gpu的ec2的启动命令--
cd /mnt/sdwebui_env/stable-diffusion-webui&&/mnt/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram 





----本地打包镜像
cd /Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo
docker build -t sand:1.0 -f Dockerfile.finally.libo  .  # 本地打包镜像
----推送本地镜像到阿里云
docker login --username=yuanxiao@playnexx registry-intl.us-east-1.aliyuncs.com  # b*****1**
docker push registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:[镜像版本号]
docker tag [ImageId] registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:[镜像版本号]