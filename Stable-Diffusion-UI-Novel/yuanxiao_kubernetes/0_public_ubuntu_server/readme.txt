vsftpd的虚拟用户配置参考笔记【vsftp配置虚拟用户访问】

https://blog.csdn.net/weixin_45444133/article/details/119203342  参考这个k8s部署



执行./install_vsftp.sh后
手动的启动vsftp服务
-------
进入到ubuntu的pod中
修改/etc/vsftpd.conf
加入负载均衡的ip地址为---------------这一步极为重要，否则被动模式下，客户端无法连接到pod中的ftp服务
pasv_address=负载均衡外网地址
-------
ps -ef|grep vsftpd|grep -v grep|awk '{print $2}'|xargs kill -9
# 启动vsftp
nohup /usr/sbin/vsftpd /etc/vsftpd.conf &
--------