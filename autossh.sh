#! /bin/bash

echo -e "输入公网服务器域名或ip: \c"
read host
echo -e "请输入要代理的端口: \c"
read port
echo -e "请输入要暴露的公网服务器端口: \c"
read remotePort
echo -e "请输入远程服务器用户名: \c"
read username
echo -e "请输入远程服务器密码: \c"
read password

echo "[ INFO ] 检测密钥对是否存在"
if [ -f ~/.ssh/id_rsa ]; then
	echo "[ INFO ] 密钥对已存在"
else
	echo "[ INFO ] 密钥对已存在"
	ssh-keygen -t rsa
fi

echo "[ INFO ] 检测是否配置免密登录"
ssh -o NumberOfPasswordPrompts=0 ${username}@${host} "pwd" &>/dev/null
if [[ $? -ne 0 ]]; then
	echo "[ WARN ] 未配置免密登录，正在配置"
	ssh-copy-id ${username}@${host}
fi

echo "[ INFO ] 检测autossh是否安装"
if command -v autossh >/dev/null 2>&1; then
	echo "[ INFO ] autossh已安装"
else
	sudo apt-get install autossh < echo ${password}
fi

echo "[ INFO ] 进程是否存在"
tmp=1000
monitorPort=`expr $remotePort - $tmp`
result=`ps -aux | grep -i "autossh -M $monitorPort -fCNR $remotePort:localhost:$port $username@$host" | grep -v "grep" | wc -l`
if [ $result -ge 1 ]; then
	echo "[ INFO ] 进程已存在，正在重启该任务"
	pid=`ps -aux | grep -i "autossh -M $monitorPort -fCNR $remotePort:localhost:$port $username@$host" | grep -v "grep" | awk '{print $2}'`
	kill -9 ${pid}
	autossh -M $monitorPort -fCNR $remotePort:localhost:$port $username@$host
else
	echo "[ INFO ] 正在重启该任务"
	autossh -M $monitorPort -fCNR $remotePort:localhost:$port $username@$host
fi