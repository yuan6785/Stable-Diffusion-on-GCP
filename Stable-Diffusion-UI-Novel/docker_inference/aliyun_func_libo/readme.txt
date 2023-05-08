登录挂载nfs的ubuntu的ec2， ubuntu22.04. 不需要gpu(如果想要完全测试，就买喊gpu的ec2即可)，只是用来编译python环境
----
按照Dockerfile.aliyun.libo的内容一步步按照python环境。python路径可以更改为/mnt的nfs路径
例如: /mnt/sdwebui_env/miniconda3/envs/sd_python310/bin/python

最后验证按照的命令--(这里不要用gpu启动，只是验证---)
/mnt/sdwebui_env/miniconda3/envs/sd_python310/bin/python  launch.py  --listen  --xformers  --medvram --skip-torch-cuda-test
这个命令会耗尽内存，关闭窗口即可结束程序