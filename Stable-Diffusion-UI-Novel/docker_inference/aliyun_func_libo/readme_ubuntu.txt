安装docker在ubunt22.04
------
sudo apt update
sudo apt upgrade
sudo apt full-upgrade

添加Docker库：
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
安装Docker Engine：
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
验证是否安装成功：
sudo docker run hello-world
------


