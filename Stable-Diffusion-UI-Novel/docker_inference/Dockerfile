FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

RUN set -ex && \
    apt update && \
    apt install -y wget git python3 python3-venv python3-pip xdg-utils && \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/cuda/lib64
RUN ln -s /usr/local/cuda/lib64/libcudart.so.11.0 /usr/local/cuda/lib64/libcudart.so

# 
WORKDIR /root
#
RUN ls -l /root
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_23.1.0-1-Linux-x86_64.sh
RUN chmod -Rf 777 Miniconda3-py38_23.1.0-1-Linux-x86_64.sh&&chmod +x Miniconda3-py38_23.1.0-1-Linux-x86_64.sh
# /root/miniconda3/envs/sd_python310/bin/python -m pip install virtualenv 或者 /root/miniconda3/bin/conda install -n sd_python310 virtualenv
# 使用 --skip-torch-cuda-test, 因为cloudbuild.yaml的machineType是没有GPU的； 另一种思路，取消这个参数，但是cloudbuild.yaml的machineType改成有GPU的也可以尝试下；
RUN set -ex \
    && bash Miniconda3-py38_23.1.0-1-Linux-x86_64.sh -b -p /root/miniconda3 \
    && /root/miniconda3/bin/conda init \
    && /root/miniconda3/bin/conda create -y --name sd_python310 python=3.10 \
    && /root/miniconda3/bin/conda install -y -n sd_python310 virtualenv \
    && git clone https://github.com/yuan6785/stable-diffusion-webui.git \
    && cd stable-diffusion-webui \
    && git checkout b791502f18b0de3e9eb93fca3aadce42878904d8 \
    && /root/miniconda3/envs/sd_python310/bin/python launch_gcp.py --skip-torch-cuda-test  \
    && git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet

# Install TensorRT and set cuda env, 这一步其实可以不要，但按原作者的思想，加进去吧
RUN set -ex \
    && /root/miniconda3/envs/sd_python310/bin/python -y install tensorrt==8.6.0
ARG CUDNN_PATH=$(dirname $(/root/miniconda3/envs/sd_python310/bin/python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))
ARG TENSORRT_PATH=$(dirname $(/root/miniconda3/envs/sd_python310/bin/python -c "import tensorrt;print(tensorrt.__file__)"))
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/cuda/lib64:$CUDNN_PATH:$TENSORRT_PATH
#
EXPOSE 7860

WORKDIR /root/stable-diffusion-webui/
CMD ["/root/miniconda3/envs/sd_python310/bin/python", "launch.py", "--listen", "--xformers",  "--medvram"]