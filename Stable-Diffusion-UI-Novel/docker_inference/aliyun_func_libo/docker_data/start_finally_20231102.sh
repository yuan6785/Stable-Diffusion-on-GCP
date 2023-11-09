echo ---------start-------$(date +"%Y-%m-%d %H:%M:%S")---------------
while getopts ":d:s:" opt;do case $opt in d) echo "domain:$OPTARG" >> /home/start_docker_params.txt;; s) echo "startmodel:$OPTARG" >> /home/start_docker_params.txt;; ?) echo "未知参数" >> /home/start_docker_params.txt;; esac done
echo ----------start read fc env-------$(date +"%Y-%m-%d %H:%M:%S")---------------
if [ -n "${FC_FUNCTION_NAME+x}" ] && [ -n "${FC_SERVICE_NAME+x}" ]; then
  VAR_FC_FUNCTION_NAME="$FC_FUNCTION_NAME";
  VAR_FC_SERVICE_NAME="$FC_SERVICE_NAME";
  echo $VAR_FC_FUNCTION_NAME;
  echo $VAR_FC_SERVICE_NAME;
else
  echo "not fc env";
fi
echo ---------start set env-------$(date +"%Y-%m-%d %H:%M:%S")---------------
CUDNN_PATH=$(dirname $(/share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20230713/bin/python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))
TENSORRT_PATH=$(dirname $(/share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20230713/bin/python -c "import tensorrt;print(tensorrt.__file__)"))
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:$CUDNN_PATH:$TENSORRT_PATH
echo ---------start rsync-------$(date +"%Y-%m-%d %H:%M:%S")---------------
if [ ! -d "/home/stable-diffusion-webui/modules" ]; then rsync -azP --no-perms --no-owner --no-group --exclude "/models" --exclude "/embeddings" --exclude "/scripts" --exclude "/samples" --exclude "/localizations" --exclude "/outputs"  /share/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui-20230713/stable-diffusion-webui/ /home/stable-diffusion-webui; fi
echo ---------start ln base-------$(date +"%Y-%m-%d %H:%M:%S")---------------
if [ ! -d "/home/stable-diffusion-webui/models" ]; then mkdir /home/stable-diffusion-webui/models; fi
for dir in Codeformer deepbooru ESRGAN GFPGAN  karlo LDSR SwinIR VAE-approx; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /share/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui-20230713/stable-diffusion-webui/models/$dir  /home/stable-diffusion-webui/models/; fi; done
for dir in ControlNet  hypernetworks  Lora  Stable-diffusion  VAE BLIP torch_deepdanbooru; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /share/sdwebui_public/public/models/$dir  /home/stable-diffusion-webui/models/; fi; done
for dir in embeddings  localizations  outputs  samples  scripts; do if [ ! -L "/home/stable-diffusion-webui/$dir" ]; then ln -s /share/sdwebui_public/public/$dir  /home/stable-diffusion-webui/; fi; done
# echo ---------start ln additional networks-------$(date +"%Y-%m-%d %H:%M:%S")---------------
# rm -rf /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/*
# ln -s /share/sdwebui_public/public/models/Lora  /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/
echo ---------start launch pre-------$(date +"%Y-%m-%d %H:%M:%S")---------------
echo "yx test 1111">/var/log/sdwebui.log
sleep 10
rm -rf /home/stable-diffusion-webui/styles.csv
ln -s /share/sdwebui_public/public/styles/styles.csv /home/stable-diffusion-webui/styles.csv
echo ---------start launch-------$(date +"%Y-%m-%d %H:%M:%S")---------------
cd /home/stable-diffusion-webui
/share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20230713/bin/python -u launch.py --port 7860 --listen --xformers --medvram --lyco-debug --lyco-patch-lora --lyco-dir ./models/Lora --skip-prepare-environment --api 2>&1 | tee /var/log/sdwebui.log
# /share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310_20230713/bin/python -m  http.server 7860 && \