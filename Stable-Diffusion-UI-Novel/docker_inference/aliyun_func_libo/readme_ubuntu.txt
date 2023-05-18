----
ssh -o StrictHostKeyChecking=no root@47.253.96.55  -i ~/workspace/0pems/sdwebui-nas-manager.pem 
非gpu机器，最好用gpu机器打包，这样启动更快(用阿里云启动模板启动 sdwebui-aliynfunc-nas-debug)

安装docker在ubunt22.04
------
sudo apt update


添加Docker库：
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
安装Docker Engine：
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
验证是否安装成功：
sudo docker run hello-world

-----gpu机器需要执行的---重要---
apt install -y nvidia-container-toolkit  # gpu机器需要安装这个
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker
------



打包进行之前进行的工作
1. 执行rsync将sd项目文件夹同步到/mnt/docker_build/docker_data下面

mkdir -p /mnt/docker_build/docker_data/stable-diffusion-webui
rsync -azP --no-perms --no-owner --no-group --exclude "/models" --exclude "/embeddings" --exclude "/scripts" --exclude "/samples" --exclude "/localizations" --exclude "/outputs"  /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/ /mnt/docker_build/docker_data/stable-diffusion-webui



2. 执行docker build创建镜像

----本地打包镜像
cd /mnt/docker_build
docker build -t sand:1.0 -f Dockerfile.finally.libo.ubuntu  .  # 只有sd的版本---如果有修改则重新复制到改目录即可
---进入容器调试(启动一下sd，下载该下载的东西，第二次启动才会更快)---记得修改config为一个小模型比如皮克斯，否则加载很慢-------
docker run -it  -v /mnt:/share sand:1.0 /bin/bash  # 非gpu
docker run -it --gpus device=all -p 9965:9965 -v /mnt:/share sand:1.0 /bin/bash  # 带gpu的---这个启动后是可以用web访问的
执行dockerfile种的CMD的launch之前的部分命令，挂载好目录---重要
#####目前是这一段#####
echo ---------start ln base-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
if [ ! -d "/home/stable-diffusion-webui/models" ]; then mkdir /home/stable-diffusion-webui/models; fi && \
for dir in Codeformer deepbooru ESRGAN GFPGAN  karlo LDSR SwinIR VAE-approx; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /share/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/models/$dir  /home/stable-diffusion-webui/models/; fi; done && \
for dir in ControlNet  hypernetworks  Lora  Stable-diffusion  VAE; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /share/sdwebui_public/public/models/$dir  /home/stable-diffusion-webui/models/; fi; done && \
for dir in embeddings  localizations  outputs  samples  scripts; do if [ ! -L "/home/stable-diffusion-webui/$dir" ]; then ln -s /share/sdwebui_public/public/$dir  /home/stable-diffusion-webui/; fi; done && \
echo ---------start ln additional networks-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
rm -rf /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/* && \
ln -s /share/sdwebui_public/public/models/Lora  /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/
########end--目前是这一段############
运行sdwebui下载该下载的，节约云函数启动时间
/share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram --skip-torch-cuda-test  # gpu的可以不带--skip-torch-cuda-test参数
当一切下载完毕后，到了Loading weights这一步，赶紧ctrl+c结束即可，否则会读虚拟内存，卡爆炸（如果是GPU机器就不用管了）
exit 退出容器
---提交容器到镜像
docker commit 容器id sand:1.0  # docker commit $(docker ps -lq) sand:1.0 
docker inspect -f '{{.Config.Cmd}}' sand:1.0  # 看容器或者镜像的启动命令即dockerfile的CMD
---二次打包（因为上面的commit命令会覆盖原来的镜像的启动CMD）----
cd /mnt/docker_build
# 如果dockerfile有改动，将Dockerfile.finally.libo.ubuntu2复制到ubuntu的目录下
docker build -t sand:2.0 -f Dockerfile.finally.libo.ubuntu2  .  # 因为上面的commit会修改dockerfile的CMD，所以需要重新打包一次
docker inspect -f '{{.Config.Cmd}}' sand:2.0
----推送本地镜像到阿里云（记得修改版本号）
docker login --username=yuanxiao@playnexx registry-intl.us-east-1.aliyuncs.com  # b*****1**
docker tag sand:2.0 registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:u13
docker push registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:u13

----删除所有镜像---
# 删除所有容器
docker rm -f $(docker ps -aq)
docker image prune -a  # 清理没有容器生成的所有镜像的存储空间

