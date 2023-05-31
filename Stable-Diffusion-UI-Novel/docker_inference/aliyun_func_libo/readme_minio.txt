----minio参考---
/Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/yuanxiao_kubernetes/0_public_minio_minio/cmds.txt

----nfs的minio机器---
ssh -o StrictHostKeyChecking=no root@47.253.96.55  -i ~/workspace/0pems/sdwebui-nas-manager.pem 
首次登录初始化已经存在的conda到环境变量
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/bin/conda init
source ~/.bashrc
conda info -e
conda activate sd_python310



---nfs同步基础模型----
cd /opt
conda activate sd_python310  # 后面强烈建议其他python包安装在其他的conda的python环境中
pip install aws-shell==0.2.2
aws configure   [秘钥参考笔记: stablediffusionwebui安装过程之谷歌云gcpgke]
# 同步基础模型
nohup aws s3 sync  s3://sd-web-ui-ec2/stable-diffusion-webui/models/Stable-diffusion-Clean  /mnt/sdwebui_public/public/models/Stable-diffusion --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步插件模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/extensions/sd-webui-controlnet/models /mnt/sdwebui_public/public/models/ControlNet --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步ti模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/embeddings /mnt/sdwebui_public/public/embeddings  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步lora模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/models/Lora /mnt/sdwebui_public/public/models/Lora  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步hypernetworks模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/models/hypernetworks /mnt/sdwebui_public/public/models/hypernetworks  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步VAE模型
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/models/VAE /mnt/sdwebui_public/public/models/VAE  --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log
# 同步scripts脚本
nohup aws s3 sync s3://sd-web-ui-ec2/stable-diffusion-webui/scripts /mnt/sdwebui_public/public/scripts --no-progress > aws_sync.log &
tail -f aws_sync.log
rm -rf aws_sync.log



------启动minio---------
cd /opt
wget  https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20220526054841.0.0_amd64.deb
dpkg -i minio_20220526054841.0.0_amd64.deb
minio server --help # 查看帮助
export MINIO_ROOT_USER=playdayy&& export MINIO_ROOT_PASSWORD=xxxxxx&&minio server --address 0.0.0.0:9001 --console-address 0.0.0.0:9002 /mnt/sdwebui_public/public  # 记得将9001/9002加入白名单, export也可以单独执行
#
nohup minio server --address 0.0.0.0:9001 --console-address 0.0.0.0:9002 /mnt/sdwebui_public/public > minio.log &
# nohup minio server --address 0.0.0.0:9001 --console-address 0.0.0.0:9002 /mnt/sd15 > minio.log &  # 测试服务
superverisor中启动
#####/etc/supervisor/supervisord.conf
[program:sdwebui-minio]  
command=bash -c "sleep 10 &&  minio server  --anonymous --address 0.0.0.0:9001 --console-address 0.0.0.0:9002 /mnt/sdwebui_public/public"  #  yxlooptask.py的内容可以看下面的记录，我记录到下面的
directory=/opt
user=root
redirect_stderr=true
autostart=true
startsecs=1
stdout_logfile=/var/log/sdwebui/minioyx.log
stopsignal=TERM
stopwaitsecs=60 
stopasgroup=true 
priority=1002
#####
superverisorctl # 看是否启动成功
tail -f /var/log/sdwebui/minioyx.log


域名访问： minio.playdayy.cn

-----nginx配置（证书保存在企业微信，杨铸里面）---------
server {
    listen 443 ssl;
    server_name minio.playdayy.cn;
    index index.html index.htm index.php;

    ssl_certificate  /etc/nginx/cert/8436159__playdayy.cn.pem;
    ssl_certificate_key /etc/nginx/cert/8436159__playdayy.cn.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://127.0.0.1:9002;
        
        client_max_body_size 15000m;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
    }
}



-----启动minio客户端------
https://dl.min.io/client/mc/release   历史版本下载
wget  https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2022-06-10T22-29-12Z
mv mc.RELEASE.2022-06-10T22-29-12Z mc
./mc -h 即可


重要(批量上传policy文件的脚本):
pyenv activate py3.10_virtualenv_test
python ./miniopers/make_policy.py  即可更新权限文件







--------如果已经配置了好了minio，配置文件在.minio.sys下面,权限文件的修改(防止权限改错了，root用户进不去)-------
/你的minio的启动目录/.minio.sys/config/iam/policies/


------权限配置minio(注意，修改权限后，需要用户刷新浏览器生效 或者 退出登录，重新登录生效)------

https://docs.aws.amazon.com/AmazonS3/latest/userguide/amazon-s3-policy-keys.html   权限编辑参考

###########################正式环境(authing版)############################################
####管理员的权限
// models, embeddings, scripts, samples四个文件夹的权限配置
// models/Lora和models/VAE只能上传，不能下载，不能删除自己的用户名文件夹
// embeddings只能上传,不能下载,不能删除自己的用户名文件夹
// scripts只能上传,不能下载,不能删除自己的用户名文件夹
// samples能上传,能下载,能删除自己的用户名文件夹
// admin_groupl.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "admin:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings/*",
                "arn:aws:s3:::localizations/*",
                "arn:aws:s3:::models/*",
                "arn:aws:s3:::samples/*",
                "arn:aws:s3:::scripts/*"
            ]
        }
    ]
}

####普通用户的权限
// models, embeddings, scripts, samples四个文件夹的权限配置
// models/Lora和models/VAE只能上传，不能下载，不能删除自己的用户名文件夹
// embeddings只能上传,不能下载,不能删除自己的用户名文件夹
// scripts只能上传,不能下载,不能删除自己的用户名文件夹
// samples能上传,能下载,能删除自己的用户名文件夹
// normal_group.json ---- ---name, aud, email
// 

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::models",
                "arn:aws:s3:::embeddings",
                "arn:aws:s3:::scripts",
                "arn:aws:s3:::samples"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::models"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "Lora/f_${jwt:email}/*",
                        "VAE/f_${jwt:email}/*",
                        "hypernetworks/f_${jwt:email}/*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::models/Lora/f_${jwt:email}/*",
                "arn:aws:s3:::models/VAE/f_${jwt:email}/*",
                "arn:aws:s3:::models/hypernetworks/f_${jwt:email}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings",
                "arn:aws:s3:::scripts",
                "arn:aws:s3:::samples"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "f_${jwt:email}/*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings/f_${jwt:email}/*",
                "arn:aws:s3:::scripts/f_${jwt:email}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::samples/f_${jwt:email}/*"
            ]
        }
    ]
}





###########################end---正式环境(authing版)######################################







###########################正式环境(用户版)######################################
####普通用户的权限
// models, embeddings, scripts, samples四个bucket的权限配置
// models/Lora和models/VAE只能上传，不能下载，不能删除自己的用户名文件夹
// embeddings只能上传,不能下载,不能删除自己的用户名文件夹
// scripts只能上传,不能下载,不能删除自己的用户名文件夹
// samples能上传,能下载,能删除自己的用户名文件夹
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::models",
                "arn:aws:s3:::embeddings",
                "arn:aws:s3:::scripts",
                "arn:aws:s3:::samples"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::models"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "Lora/${aws:username}/*",
                        "VAE/${aws:username}/*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::models/Lora/${aws:username}/*",
                "arn:aws:s3:::models/VAE/${aws:username}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings",
                "arn:aws:s3:::scripts",
                "arn:aws:s3:::samples"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "${aws:username}/*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings/${aws:username}/*",
                "arn:aws:s3:::scripts/${aws:username}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::samples/${aws:username}/*"
            ]
        }
    ]
}


// 这个是不分用户的----阿里云训练机版本
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings",
                "arn:aws:s3:::models",
                "arn:aws:s3:::samples",
                "arn:aws:s3:::scripts"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::models"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "VAE/*",
                        "Lora/*",
                        "lora/*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::models/Lora/*",
                "arn:aws:s3:::models/lora/*",
                "arn:aws:s3:::models/VAE/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::models/lora/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::samples",
                "arn:aws:s3:::scripts",
                "arn:aws:s3:::embeddings"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::scripts/*",
                "arn:aws:s3:::embeddings/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::samples/*"
            ]
        }
    ]
}



###########################end 正式环境(用户版)##################################















------权限配置minio--一些测试有用的配置(注意，修改权限后，需要用户刷新浏览器生效 或者 退出登录，重新登录生效)-----------------------------------------------这些是重要的参考
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



-----admin只读s3权限-------
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "admin:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}


-----非admin所有指定文件夹目录的权限(重要--bucket的文件夹权限设置)-------
// s3有一个bucket叫embeddings,  下面有一个文件夹haha。 我只允许用户能在haha上传文件，查看haha的文件列表，但不能下载，该如何写这个权限配置文件policy
// 下面的每一段都比较重要
// 1. 是允许用户查看embeddings这个bucket的列表
// 2. 是允许用户查看embeddings这个bucket下面haha这个文件夹的文件列表
// 3. 是允许用户上传文件到embeddings这个bucket下面haha这个文件夹, 如果有其他允许的权限，请加在这一段即可
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::embeddings"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "haha/*"  
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings/haha/*"
            ]
        }
    ]
}

根据登录用户名动态配置---将上面的haha换为${aws:username}/*即可-----文件夹不存在会自己重建-----重要---
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::embeddings"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "${aws:username}/*"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::embeddings/${aws:username}/*"
            ]
        }
    ]
}



// 动态policy ---  根据用户名配置
https://min.io/docs/minio/linux/administration/identity-access-management/policy-based-access-control.html







下面是正式权限配置:
铸哥用的预权限文件,后面我替换即可
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::localizations/*"
            ]
        }
    ]
}