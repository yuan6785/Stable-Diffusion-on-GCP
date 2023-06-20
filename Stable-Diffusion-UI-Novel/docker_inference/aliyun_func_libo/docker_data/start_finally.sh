echo ---------start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
while getopts ":d:s:" opt;do case $opt in d) echo "domain:$OPTARG" >> /home/start_docker_params.txt;; s) echo "startmodel:$OPTARG" >> /home/start_docker_params.txt;; ?) echo "未知参数" >> /home/start_docker_params.txt;; esac done
echo ---------start set env-------$(date +"%Y-%m-%d %H:%M:%S")---------------
CUDNN_PATH=$(dirname $(/share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))
TENSORRT_PATH=$(dirname $(/share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -c "import tensorrt;print(tensorrt.__file__)"))
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:$CUDNN_PATH:$TENSORRT_PATH
echo ---------start rsync-------$(date +"%Y-%m-%d %H:%M:%S")---------------
if [ ! -d "/home/stable-diffusion-webui/modules" ]; then rsync -azP --no-perms --no-owner --no-group --exclude "/models" --exclude "/embeddings" --exclude "/scripts" --exclude "/samples" --exclude "/localizations" --exclude "/outputs"  /share/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/ /home/stable-diffusion-webui; fi
echo ---------start ln base-------$(date +"%Y-%m-%d %H:%M:%S")---------------
if [ ! -d "/home/stable-diffusion-webui/models" ]; then mkdir /home/stable-diffusion-webui/models; fi
for dir in Codeformer deepbooru ESRGAN GFPGAN  karlo LDSR SwinIR VAE-approx; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /share/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/models/$dir  /home/stable-diffusion-webui/models/; fi; done
for dir in ControlNet  hypernetworks  Lora  Stable-diffusion  VAE; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /share/sdwebui_public/public/models/$dir  /home/stable-diffusion-webui/models/; fi; done
for dir in embeddings  localizations  outputs  samples  scripts; do if [ ! -L "/home/stable-diffusion-webui/$dir" ]; then ln -s /share/sdwebui_public/public/$dir  /home/stable-diffusion-webui/; fi; done
echo ---------start ln additional networks-------$(date +"%Y-%m-%d %H:%M:%S")---------------
rm -rf /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/*
ln -s /share/sdwebui_public/public/models/Lora  /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/
echo ---------start launch-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo "yx test 1111">/var/log/sdwebui.log
sleep 10
cd /home/stable-diffusion-webui
/share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -u launch.py --port 7860 --listen --xformers --medvram --api 2>&1 | tee /var/log/sdwebui.log
# /share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -m  http.server 7860 && \