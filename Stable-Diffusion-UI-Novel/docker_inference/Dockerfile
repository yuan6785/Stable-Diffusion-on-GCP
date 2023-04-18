FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

RUN set -ex && \
    apt update && \
    apt install -y wget git python3 python3-venv python3-pip xdg-utils && \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/cuda/lib64
RUN ln -s /usr/local/cuda/lib64/libcudart.so.11.0 /usr/local/cuda/lib64/libcudart.so

RUN groupadd -r sd3 && useradd --create-home -r -g sd3 sd3
USER sd3

# 
WORKDIR /home/sd3
RUN ls -l /home/sd3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_23.1.0-1-Linux-x86_64.sh
RUN git clone https://github.com/yuan6785/stable-diffusion-webui.git
RUN chmod -Rf 777 Miniconda3-py38_23.1.0-1-Linux-x86_64.sh && chmod +x 777 Miniconda3-py38_23.1.0-1-Linux-x86_64.sh
RUN set -ex \
    && bash Miniconda3-py38_23.1.0-1-Linux-x86_64.sh -b -p /home/sd3/miniconda3 \
    && /home/sd3/miniconda3/bin/conda init \
    && source ~/.bashrc \
    && conda create --name sd_python310 python=3.10 \
    && conda activate sd_python310 \
    && python -m pip install virtualenv \
    && cd stable-diffusion-webui \
    && bash <(wget -qO- https://raw.githubusercontent.com/yuan6785/stable-diffusion-webui/b791502f18b0de3e9eb93fca3aadce42878904d8/webui-conda-yuanxiao-gcp.sh) \
    && git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet


EXPOSE 7860

WORKDIR /home/sd3/stable-diffusion-webui/
CMD ["/home/sd3/miniconda3/envs/sd_python310/bin/python", "launch.py", "--listen", "--xformers",  "--medvram"]