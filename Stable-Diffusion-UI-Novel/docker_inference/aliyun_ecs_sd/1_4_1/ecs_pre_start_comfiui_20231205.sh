#!bin/bash
# /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh  #记得 chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh
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
echo ---------end pre-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo ---------start launch pre-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo ---------start sd server-------$(date +"%Y-%m-%d %H:%M:%S")---------------
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/bin/conda init
chmod +x ~/.bashrc
. ~/.bashrc
eval "$(/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/bin/conda shell.bash hook)"
conda activate comfyui_python310_20231205
python -c "import sys; print(sys.executable)" &&
    cd /home/ComfyUI &&
    echo "end rsync" >yx_end_rsync.txt &&
    /mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/comfyui_python310_20231205/bin/python main.py --listen 0.0.0.0 --port 9965
echo ---------end-------$(date +"%Y-%m-%d %H:%M:%S")---------------
