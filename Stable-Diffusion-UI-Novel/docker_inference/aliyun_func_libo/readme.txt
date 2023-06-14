/Users/yuanxiao/workspace/0yxgithub/Stable-Diffusion-on-GCP/Stable-Diffusion-UI-Novel/docker_inference/aliyun_func_libo/Dockerfile.finally.libo.supervisor2 ------ 重要参考 
Dockerfile.finally.libo.supervisor3 ------ 重要参考
######
提示：按量实例在处理完请求后会被冻结，如果一段时间内（一般为3~5分钟）不再处理请求，会自动销毁。------重要(冻结cpu的期间无法后台处理程序)----
######
解决云函数无法启动后台启动sd的问题, 是由于云函数只有在访问期间cpu才不会被冻结，这里通过一个技巧绕过去，就是在云函数启动一个web服务，启动一个需要120秒才能拿到结果的http接口，这期间cpu不会被冻结， 120秒期间启动sd足够了
######


#####参考Dockerfile.finally.libo.supervisor3的CMD注释
# 注意(写在dockerfile的CMD之前的注释):
# 1. 注意命令中不能有 (当最后一条命令还没有启动起来, nginx访问返回http请求信息的服务)----会导致最后一条命令无法启动 
#     当云函数启动后，只有在访问云函数期间，cpu才不会被冻结。所以当第一次http请求成功后，cpu被冻结，可能导致其他需要时间的服务无法启动
# 2. 当nignx配置多条转发路径，其中一条命令执行时间比较长(120秒左右)，会导致启动另外的实例，大于一个实例。(我也只限制了1个实例 但是还是会启动多个)
# 3. 下面的命令必须是幂等的，如果在同一实例重启不要报错 
# 4. 要像云函数不释放，必须是执行dockerfile的最后一个前台服务的请求，即卡住docker的最后一条任务的请求。
#    如果请求的非前台服务的其他服务的请求，虽然端口都是docker暴露端口，但是还是无法保活，云函数会在一段时间后释放
#    这一条很可能和第二条是一个原理，如果一个请求时间太长，会导致启动多个实例，导致原实例被释放(我也只限制了1个实例 但是还是会启动多个)

# 记录一次测试----
# c-64898a1e-f45d4dac86a54d42be0d   2023-06-14 17:36:34  17:55最后一张图， 然后用非卡住docker的后台任务进行保活测试  18:38都没有释放，说明非卡住docker的后台任务可以保活（但是执行时间不能太长，不能有supervisor的web访问和其他非卡主docker的服务器的长时间的访问，长时间的需要前端页面轮询）
#####

readme_ubuntu.txt 是在ubuntu下的用docker安装的说明， 这个需要生成两次镜像，但是启动时间短

readme_debug.txt 是直接用dockerfile生成镜像，可以在mac上面直接打包 -------- 后面用这个

readme_minio.txt 是配置minio的文档


u13---ubuntu打包的镜像  （皮克斯模型---启动时间18:20:23--18:21:47  84秒启动）
v67, v69---mac打包的镜像      (anything模型---启动时间18:35:05--18:36:59  114秒启动）
v67, v69---mac打包的镜像      (皮克斯模型---启动时间18:53:05--18:54:12  67秒启动）
u33 --- 最后一个带supervisor的镜像

使用文档
https://confluence.playnexx.net/pages/viewpage.action?pageId=82576211




阿里云函数第一版的sdwebui推理服务器已经部署完成， 目前的做法是我们预准备了
5.sd.play1.net   到   50.sd.play1.net   一共45个推理服务器；  1-5的供我们技术测试用。

这个是使用说明， 目前的资源已经实现了服务器管理
https://confluence.playnexx.net/pages/viewpage.action?pageId=82576211


麻烦戴文你先用  1.sd.play1.net 测试两天看看使用效果，你如果觉得没有问题的话，再大量推广




后面： 用户只需要分配对应的域名即可， 可能需要你那边去给他们分配下域名，需要准备类似每天分配服务器那么一张表来填域名


重要(批量上传policy文件的脚本):
pyenv activate py3.10_virtualenv_test
python ./miniopers/make_policy.py  即可更新权限文件