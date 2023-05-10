----nfs的minio机器---
ssh -o StrictHostKeyChecking=no root@47.253.96.55  -i ~/workspace/0pems/sdwebui-nas-manager.pem 
首次登录初始化已经存在的conda到环境变量
/mnt/sdwebui_env/miniconda3/bin/conda init
source ~/.bashrc
conda info -e
conda activate sd_python310



---nfs同步基础模型----
cd /opt
conda activate sd_python310  # 后面强烈建议其他python包安装在其他的conda的python环境中
pip install aws-shell==0.2.2
aws configure   [秘钥参考笔记: stablediffusionwebui安装过程之谷歌云gcpgke]
# 同步基础模型
nohup aws s3 sync  s3://sd-web-ui-ec2/stable-diffusion-webui/models/Stable-diffusion-Clean  /mnt/sdwebui_env/stable-diffusion-webui/models/Stable-diffusion --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步插件模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/extensions/sd-webui-controlnet/models /mnt/sdwebui_env/stable-diffusion-webui/models/ControlNet --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步ti模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/embeddings /mnt/sdwebui_env/stable-diffusion-webui/embeddings  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步lora模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/models/Lora /mnt/sdwebui_env/stable-diffusion-webui/models/Lora  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步hypernetworks模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/models/hypernetworks /mnt/sdwebui_env/stable-diffusion-webui/models/hypernetworks  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步VAE模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/models/VAE /mnt/sdwebui_env/stable-diffusion-webui/models/VAE  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步scripts脚本
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/scripts /mnt/sdwebui_env/stable-diffusion-webui/scripts --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log

