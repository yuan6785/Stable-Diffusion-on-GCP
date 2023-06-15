登录挂载nfs的ubuntu的ec2， ubuntu22.04. 不需要gpu(如果想要完全测试，就买含gpu的ec2即可)，只是用来编译python环境
----
apt-get install nvidia-driver-460  # 安装显卡驱动
nvidia-smi # 查看显卡驱动是否安装成功
按照Dockerfile.aliyun.libo的内容一步步按照python环境。python路径可以更改为/mnt的nfs路径
例如: /mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python
---
我的调试镜像打包好的:  sdwebui-aliynfunc-nas-debug（含GPU的）。
实例启动模板: sdwebui-aliynfunc-nas-debug （用上面的镜像和相关机型的，直接用即可）
如果内存不够: 最好创建一个虚拟内存----todo
---
也可以直接在云函数中"登录实例"--进入docker镜像中， 进行调试
---调试rsync--
rsync -azP --no-perms --no-owner --no-group --exclude '/models' --exclude '/embeddings' --exclude '/scripts' --exclude '/samples' --exclude '/localizations' --exclude '/outputs'  /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/ /home/stable-diffusion-webui   


最后验证按照的命令--(如果用的非gpu机器启动的， 这里不要用gpu启动，只是验证---)
cd /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram --skip-torch-cuda-test
如果是非gpu的ec2，这个命令会耗尽内存，关闭窗口即可结束程序


带gpu的ec2的启动命令--
cd /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui&&/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram 



----解决阿里云函数无法用ssl下载模型的问题(重要---重启云函数才会生效---)------
修改源码 vi /mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/lib/python3.10/urllib/request.py
###############
1346         try:
1347             try:
1348                 # modify by yx --disabled ssl
1349                 import ssl
1350                 ssl._create_default_https_context = ssl._create_unverified_context
1351                 print("yx--modify-ssl--")
1352                 # end --- modify by yx
1353                 h.request(req.get_method(), req.selector, req.data, headers,
1354                           encode_chunked=req.has_header('Transfer-encoding'))
1355             except OSError as err: # timeout error
1356                 raise URLError(err)
1357             r = h.getresponse()
1358         except:
1359             h.close()
1360             raise
###############



----本地打包镜像
cd /Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo
# docker build -t sand:1.0 -f Dockerfile.finally.libo.supervisor  .  # 本地打包镜像--supervisor版本--有问题，启动不起来
# docker build -t sand:1.0 -f Dockerfile.finally.libo.supervisor2  .  # 本地打包镜像--supervisor2版本--可以启动了，但是用sd生成
几次图片后，实例就会被释放 ----- 重要参考
# docker build -t sand:1.0 -f Dockerfile.finally.libo  .  # 只有sd的版本
docker build -t sand:1.0 -f Dockerfile.finally.libo.supervisor3  .  # 只有sd的版本
---进入容器调试
docker run -it --rm sand:1.0 /bin/bash
---------推送本地镜像到阿里云（记得修改版本号 u58）-------美东--------
            docker login --username=yuanxiao@playnexx registry-intl.us-east-1.aliyuncs.com  # b*****1**
            ----
            Dockerfile.finally.libo
            -->
            docker tag sand:1.0 registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:v69
            docker push registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:v69
            ----
            Dockerfile.finally.libo.supervisor2
            -->
            docker tag sand:1.0 registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:2u3
            docker push registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:2u3
            ----
            Dockerfile.finally.libo.supervisor3
            -->
            docker tag sand:1.0 registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:u58
            docker push registry-intl.us-east-1.aliyuncs.com/talefun/stable-diffusion-images:u58
---------推送本地镜像到阿里云（记得修改版本号）------新加坡--------
            docker login --username=yuanxiao@playnexx registry-intl.ap-southeast-1.aliyuncs.com  # b*****1**
            docker tag sand:1.0 registry-intl.ap-southeast-1.aliyuncs.com/talefun/stable-diffusion-images:v70
            docker push registry-intl.ap-southeast-1.aliyuncs.com/talefun/stable-diffusion-images:v70
----清理镜像
docker images
docker rmi -f sand:1.0
docker image prune -a  # 清理没有容器生成的所有镜像的存储空间









另外一种调试方法(带GPU的)--------复制到home目录模拟云函数环境进行调试---------
我的调试镜像打包好的:  sdwebui-aliynfunc-nas-debug（含GPU的）。
实例启动模板: sdwebui-aliynfunc-nas-debug （用上面的镜像和相关机型的，直接用即可）--------
--------------到带gpu的服务器执行下面命令----------------

/bin/sh -c 'echo ---------start-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
echo ---------start set env-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
CUDNN_PATH=$(dirname $(/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)")) && \
TENSORRT_PATH=$(dirname $(/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -c "import tensorrt;print(tensorrt.__file__)")) && \
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:$CUDNN_PATH:$TENSORRT_PATH && \
echo ---------start rsync-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
if [ ! -d "/home/stable-diffusion-webui/modules" ]; then rsync -azP --no-perms --no-owner --no-group --exclude "/models" --exclude "/embeddings" --exclude "/scripts" --exclude "/samples" --exclude "/localizations" --exclude "/outputs"  /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/ /home/stable-diffusion-webui; fi && \
echo ---------start ln base-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
if [ ! -d "/home/stable-diffusion-webui/models" ]; then mkdir /home/stable-diffusion-webui/models; fi && \
for dir in Codeformer deepbooru ESRGAN GFPGAN  karlo LDSR SwinIR VAE-approx; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /mnt/sdwebui_public/versions/sdwebui_env/stable-diffusion-webui/models/$dir  /home/stable-diffusion-webui/models/; fi; done && \
for dir in ControlNet  hypernetworks  Lora  Stable-diffusion  VAE; do if [ ! -L "/home/stable-diffusion-webui/models/$dir" ]; then ln -s /mnt/sdwebui_public/public/models/$dir  /home/stable-diffusion-webui/models/; fi; done && \
for dir in embeddings  localizations  outputs  samples  scripts; do if [ ! -L "/home/stable-diffusion-webui/$dir" ]; then ln -s /mnt/sdwebui_public/public/$dir  /home/stable-diffusion-webui/; fi; done && \
echo ---------start ln additional networks-------$(date +"%Y-%m-%d %H:%M:%S")--------------- && \
rm -rf /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/* && \
ln -s /mnt/sdwebui_public/public/models/Lora  /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/
'

启动(可以在home目录下自行调试，不影响云函数的运行)---
cd /home/stable-diffusion-webui
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram 


例如调试扩展： /home/stable-diffusion-webui/extensions/sd-webui-additional-networks
rm -rf /home/stable-diffusion-webui/extensions/sd-webui-additional-networks
cp -r /mnt/bak/extensions/sd-webui-additional-networks /home/stable-diffusion-webui/extensions/sd-webui-additional-networks
ln -s /mnt/sdwebui_public/public/models/Lora  /home/stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora/
vi extensions/sd-webui-additional-networks/scripts/model_util.py
修改164行的函数为下面的(这个可以检查lora是否完整---原来的功能是不完整则不启动sd, 我改为了打印出来不完整的lora文件名，但还是启动sd，不将错误的lora显示在下拉列表):
解决报错: 
[AddNet] Updating model hashes... 
Error loading script: model_util.py
RuntimeError: self.size(-1) must be divisible by 4 to view Byte as Float (different element sizes), but got 689998
####################
def hash_model_file(finfo):
    filename = finfo[0]
    stat = finfo[1]
    name = os.path.splitext(os.path.basename(filename))[0]

    # Prevent a hypothetical "None.pt" from being listed.
    if name != "None":
        metadata = None

        cached = cache("hashes").get(filename, None)
        if cached is None or stat.st_mtime != cached["mtime"]:
            if metadata is None and model_util.is_safetensors(filename):
                try:
                    metadata = safetensors_hack.read_metadata(filename)
                except Exception as ex:
                    return {"error": ex, "filename": filename}
            model_hash = get_model_hash(metadata, filename)
            # modify by yx
            # legacy_hash = get_legacy_hash(metadata, filename)
            try:
                legacy_hash = get_legacy_hash(metadata, filename)
            except Exception as ex:
                print(111111, 'yx print----', filename)
                return {"error": ex, "filename": filename}
            # end-modify by yx
        else:
            model_hash = cached["model"]
            legacy_hash = cached["legacy"]

    return {"model": model_hash, "legacy": legacy_hash, "fileinfo": finfo}
####################

启动即可:
cd /home/stable-diffusion-webui
/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen --port 9965  --xformers  --medvram 


调试完成后: 删除/home/stable-diffusion-webui即可