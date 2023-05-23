readme_ubuntu.txt 是在ubuntu下的用docker安装的说明， 这个需要生成两次镜像，但是启动时间短

readme_debug.txt 是直接用dockerfile生成镜像，可以在mac上面直接打包

readme_minio.txt 是配置minio的文档


u13---ubuntu打包的镜像  （皮克斯模型---启动时间18:20:23--18:21:47  84秒启动）
v67---mac打包的镜像      (anything模型---启动时间18:35:05--18:36:59  114秒启动）
v67---mac打包的镜像      (皮克斯模型---启动时间18:53:05--18:54:12  67秒启动）


使用文档
https://confluence.playnexx.net/pages/viewpage.action?pageId=82576211




阿里云函数第一版的sdwebui推理服务器已经部署完成， 目前的做法是我们预准备了
5.sd.play1.net   到   50.sd.play1.net   一共45个推理服务器；  1-5的供我们技术测试用。

这个是使用说明， 目前的资源已经实现了服务器管理
https://confluence.playnexx.net/pages/viewpage.action?pageId=82576211


麻烦戴文你先用  1.sd.play1.net 测试两天看看使用效果，你如果觉得没有问题的话，再大量推广




后面： 用户只需要分配对应的域名即可， 可能需要你那边去给他们分配下域名，需要准备类似每天分配服务器那么一张表来填域名