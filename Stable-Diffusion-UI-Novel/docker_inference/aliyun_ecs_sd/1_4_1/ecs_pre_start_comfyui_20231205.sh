#!bin/bash
# /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh  #记得 chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh
# comfyui的版本构建参考笔记[comfyui的安装]
echo ---------start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
# sleep 10 && \
echo ---------start set env-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo ---------start rsync-------$(date +"%Y-%m-%d %H:%M:%S")---------------
if [ ! -d "/home/ComfyUI/models" ]; then
    rsync -azP --no-perms --no-owner --no-group --exclude "/output" /mnt/sdwebui_public/versions/sdwebui_env/comfyui-20231205/ComfyUI/ /home/ComfyUI
fi
echo ---------start update extensions-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo ---------start ln base-------$(date +"%Y-%m-%d %H:%M:%S")---------------
if [ ! -L "/home/ComfyUI/models/checkpoints/Stable-diffusion" ]; then
    ln -s /mnt/sdwebui_public/public/models/Stable-diffusion /home/ComfyUI/models/checkpoints/
fi
if [ ! -L "/home/ComfyUI/models/controlnet/ControlNetNormal" ]; then
    ln -s /mnt/sdwebui_public/public/models/ControlNet/ControlNetNormal /home/ComfyUI/models/controlnet/
fi
if [ ! -L "/home/ComfyUI/models/controlnet/ControlNetXL" ]; then
    ln -s /mnt/sdwebui_public/public/models/ControlNet/ControlNetXL /home/ComfyUI/models/controlnet/
fi
if [ ! -L "/home/ComfyUI/models/vae/VAE" ]; then
    ln -s /mnt/sdwebui_public/public/models/VAE /home/ComfyUI/models/vae/
fi
if [ ! -L "/home/ComfyUI/models/hypernetworks/hypernetworks" ]; then
    ln -s /mnt/sdwebui_public/public/models/hypernetworks /home/ComfyUI/models/hypernetworks/
fi
if [ ! -L "/home/ComfyUI/models/embeddings/embeddings" ]; then
    ln -s /mnt/sdwebui_public/public/embeddings /home/ComfyUI/models/embeddings/
fi
if [ ! -L "/home/ComfyUI/models/clip_vision/clip_vision" ]; then
    ln -s /mnt/sdwebui_public/public/models/clip_vision /home/ComfyUI/models/clip_vision
fi
# add by yx 20240205---判断/home/ComfyUI/models/ipadapter是否存在不存在则创建
if [ ! -d "/home/ComfyUI/models/ipadapter" ]; then
    mkdir /home/ComfyUI/models/ipadapter
fi
if [ ! -L "/home/ComfyUI/models/ipadapter/ipadapter" ]; then
    ln -s /mnt/sdwebui_public/public/models/ipadapter /home/ComfyUI/models/ipadapter
fi
# end add by yx 20240205
if [ ! -L "/home/ComfyUI/models/upscale_models/upscale_models" ]; then
    ln -s /mnt/sdwebui_public/public/models/upscale_models /home/ComfyUI/models/upscale_models/
fi
if [ ! -L "/home/ComfyUI/models/loras/Lora" ]; then
    ln -s /mnt/sdwebui_public/public/models/Lora /home/ComfyUI/models/loras/
fi
# 这个先不做,因为不清楚文件名格式,害怕越来越多
# if [ ! -L "/home/ComfyUI/output" ]; then
#     ln -s /mnt/sdwebui_public/public/outputs/comfyui  /home/ComfyUI/output
# fi
/mnt/sdwebui_public/public/outputs
echo ---------end pre-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo ---------start launch pre-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo ---------start sd server-------$(date +"%Y-%m-%d %H:%M:%S")---------------
# if [ false ]; then
#     /mnt/sdwebui_public/versions/sdwebui_env/miniconda3/bin/conda init
#     chmod +x ~/.bashrc
#     . ~/.bashrc
#     eval "$(/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/bin/conda shell.bash hook)"
#     conda activate comfyui_python310_20231205
#     python -c "import sys; print(sys.executable)"
#     cd /home/ComfyUI
#     echo "end rsync" >yx_end_rsync.txt
#     /mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/comfyui_python310_20231205/bin/python main.py --listen 0.0.0.0 --port 9965
# fi
if [ true ]; then
    /root/miniconda3/bin/conda init
    chmod +x ~/.bashrc
    . ~/.bashrc
    eval "$(/root/miniconda3/bin/conda shell.bash hook)"
    conda activate comfyui_python310_20231205
    python -c "import sys; print(sys.executable)"
    cd /home/ComfyUI
    echo "end rsync" >yx_end_rsync.txt
    /root/miniconda3/envs/comfyui_python310_20231205/bin/python main.py --listen 0.0.0.0 --port 9965
fi
echo ---------end-------$(date +"%Y-%m-%d %H:%M:%S")---------------
