# /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_minio.sh  文件实例,  chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_minio.sh
# 我测试是成功的----管理员playdayy  bbqbbq123  ; 普通用户: ecsuser   ecsuserqwe
# 策略文件和minio安装搜索 /Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo/readme_minio.txt // 这个是不分用户的----阿里云训练机版本
# 判断/home/stable-diffusion-webui/yx_end_rsync.txt这个文件是否存在，如果存在则开始执行下面的，不存在则等待1秒
echo ---------start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
sleep 10
while [ ! -f "/home/ComfyUI/yx_end_rsync.txt" ]; do sleep 1; done
echo ---------real start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
rm -rf  /home/ComfyUI/.minio.sys && cp -rf /mnt/bak/ecs141_minio_comfyui.sys /home/ComfyUI/.minio.sys
export MINIO_ROOT_USER=playdayy && export MINIO_ROOT_PASSWORD=bbqbbq123 &&  minio server  --anonymous --address 0.0.0.0:9002 --console-address 0.0.0.0:9003 /home/ComfyUI

export MINIO_ROOT_USER=playdayy && export MINIO_ROOT_PASSWORD=bbqbbq123 &&  minio server  --anonymous --address 0.0.0.0:9004 --console-address 0.0.0.0:9005 /home/ComfyUI