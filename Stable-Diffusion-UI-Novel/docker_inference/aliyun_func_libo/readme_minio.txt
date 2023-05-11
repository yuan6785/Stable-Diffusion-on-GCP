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



------启动minio---------
cd /opt
wget  https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20220526054841.0.0_amd64.deb
dpkg -i minio_20220526054841.0.0_amd64.deb
minio server --help # 查看帮助
export MINIO_ROOT_USER=playdayy&& export MINIO_ROOT_PASSWORD=xxxxxx&&minio server --address 0.0.0.0:9001 --console-address 0.0.0.0:9002 /mnt/sdwebui_env/stable-diffusion-webui  # 记得将9001/9002加入白名单, export也可以单独执行
#
minio server --address 0.0.0.0:9001 --console-address 0.0.0.0:9002 /mnt/sd15


-----启动minio客户端------
https://dl.min.io/client/mc/release   历史版本下载
wget  https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2022-06-10T22-29-12Z
mv mc.RELEASE.2022-06-10T22-29-12Z mc
./mc -h 即可


------权限配置minio----------
// 权限参考 https://min.io/docs/minio/linux/administration/identity-access-management/policy-based-access-control.html
// 这个策略包括了以下几个部分：
// 允许列出bucket yxtest中的对象列表。
// 禁止下载bucket yxtest中的对象。
// 允许上传对象到bucket yxtest。
// 允许修改bucket yxtest中对象的ACL。
// 禁止删除bucket yxtest中的对象。
// 请注意，这个策略只适用于bucket yxtest中的文件，而不是整个bucket。如果您想要对整个bucket进行限制，请将Resource字段改为"arn:aws:s3:::yxtest"。

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::yxtest"
            ]
        },
        {
            "Sid": "GetObject",
            "Effect": "Deny",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::yxtest/*"
            ]
        },
        {
            "Sid": "PutObject",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::yxtest/*"
            ]
        },
        {
            "Sid": "DeleteObject",
            "Effect": "Deny",
            "Action": [
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::yxtest/*"
            ]
        }
    ]
}