apt update
apt -y install vsftpd db-util
mkdir -p /var/run/vsftpd/empty
echo $(vsftpd -v)
echo "local_enable=YES
pam_service_name=vsftpd
anonymous_enable=NO
listen=YES
listen_ipv6=NO
guest_enable=YES
guest_username=FTP
user_config_dir=/etc/vsftpd_yx/vuser_conf/
allow_writeable_chroot=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pasv_enable=YES
pasv_min_port=20000
pasv_max_port=20045">/etc/vsftpd.conf
mkdir -p /etc/vsftpd_yx
cd  /etc/vsftpd_yx
echo "playdayy
1
playdayy_admin
pla12345">/etc/vsftpd_yx/vuser
cd  /etc/vsftpd_yx&&db_load -T -t hash -f vuser vuser.db
echo "auth       required     /usr/lib/x86_64-linux-gnu/security/pam_userdb.so   db=/etc/vsftpd_yx/vuser 
account    required     /usr/lib/x86_64-linux-gnu/security/pam_userdb.so   db=/etc/vsftpd_yx/vuser">/etc/pam.d/vsftpd
cd  /etc/vsftpd_yx&&mkdir -p vuser_conf&&cd /etc/vsftpd_yx/vuser_conf/
userisexist=$(id -u FTP >/dev/null 2>&1 || echo "User does not exist")
if [[ ! -z "${userisexist}" ]]; then
    useradd --create-home -s /sbin/nologin FTP
else
    echo "User already exists"
fi
runuser FTP -s /bin/bash -c 'mkdir -p /home/FTP/playdayy&&echo "1" > /home/FTP/playdayy/1.txt' 
echo "local_root=/home/FTP/playdayy
write_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
anon_umask=000">/etc/vsftpd_yx/vuser_conf/playdayy
echo "local_root=/home/FTP/playdayy
write_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
anon_umask=000">/etc/vsftpd_yx/vuser_conf/playdayy_admin
# 先杀死vsftpd进程,先找出进程号,然后杀死进程，一句代码执行, 进程不存不要报错
# ps -ef|grep vsftpd|grep -v grep|awk '{print $2}'|xargs kill -9
# 启动vsftp
# nohup /usr/sbin/vsftpd /etc/vsftpd.conf &
echo "end"
