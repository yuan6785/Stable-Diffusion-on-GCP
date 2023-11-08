#!bin/bash
# /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh  #记得 chmod +x /mnt/sdwebui_public/ecs_versions/1_4_1/ecs_pre_start.sh
echo ---------start-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
# sleep 10 && \
echo ---------start set env-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
CUDNN_PATH=$(dirname $(/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20231102/bin/python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)")) && \
TENSORRT_PATH=$(dirname $(/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20231102/bin/python -c "import tensorrt;print(tensorrt.__file__)")) && \
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:$CUDNN_PATH:$TENSORRT_PATH && \
echo ---------start rsync-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
if [ ! -d "/home/stable-diffusion-webui/modules" ]; then rsync -azP --no-perms --no-owner --no-group --exclude "/models/ControlNet" --exclude "/models/hypernetworks" --exclude "/models/Stable-diffusion" --exclude "/models/VAE" --exclude "/models/dreambooth" --exclude "/models/Lora" --exclude "/models/lora" --exclude "/models/BLIP" --exclude "/models/torch_deepdanbooru"  --exclude "/embeddings" --exclude "/scripts" --exclude "/samples" --exclude "/localizations" --exclude "/outputs"  /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui-20231102/stable-diffusion-webui/ /home/stable-diffusion-webui; fi && \
echo ---------start ln base-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
for dir in  hypernetworks  Stable-diffusion BLIP torch_deepdanbooru; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /mnt/sdwebui_public/public/models/$dir  /home/stable-diffusion-webui/models/; fi; done && \
for dir in  ControlNetXL; do if [ ! -L "/home/stable-diffusion-webui/models/ControlNet" ]; then ln -s /mnt/sdwebui_public/public/models/$dir  /home/stable-diffusion-webui/models/ControlNet; fi; done && \
for dir in VAE; do if [ ! -d "/home/stable-diffusion-webui/models/$dir" ]; then cp -rf /mnt/sdwebui_public/public/models/$dir  /home/stable-diffusion-webui/models/; fi; done && \
if [ ! -d "/home/stable-diffusion-webui/models/Lora" ]; then mkdir /home/stable-diffusion-webui/models/Lora; fi && \
for dir in  outputs; do if [ ! -L "/home/stable-diffusion-webui/$dir" ]; then ln -s /mnt/sdwebui_public/public/$dir  /home/stable-diffusion-webui/; fi; done && \
for dir in localizations20231102; do if [ ! -L "/home/stable-diffusion-webui/localizations" ]; then ln -s /mnt/sdwebui_public/public/$dir  /home/stable-diffusion-webui/localizations; fi; done && \
for dir in embeddings  samples  scripts; do if [ ! -d "/home/stable-diffusion-webui/$dir" ]; then cp -rf /mnt/sdwebui_public/public/$dir  /home/stable-diffusion-webui/; fi; done && \
echo ---------end pre-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
echo ---------start launch pre-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
sleep 2 && \
rm -rf /home/stable-diffusion-webui/styles.csv && \
ln -s /mnt/sdwebui_public/public/styles/styles.csv /home/stable-diffusion-webui/styles.csv && \
echo ---------start sd server-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/bin/conda init;chmod +x ~/.bashrc;. ~/.bashrc;eval "$(/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/bin/conda shell.bash hook)";conda activate sd_python310_20231102;python -c "import sys; print(sys.executable)" && \
cd /home/stable-diffusion-webui && \
echo "end rsync">yx_end_rsync.txt && \
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20231102/bin/python  launch.py  --listen --port 9965  --xformers  --medvram --skip-prepare-environment
echo ---------end-------$(date +"%Y-%m-%d %H:%M:%S")---------------