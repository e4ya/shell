#!/bin/bash
function newnode {	
	if ps -ef | grep "nginx"|egrep -v grep	> /dev/null
		then
			echo 正在关闭Nginx和Nginx开机自启动
			chkconfig nginx off > /dev/null
			/etc/init.d/nginx stop > /dev/null
			rm -rf /etc/init.d/nginx > /dev/null
			systemctl stop nginx.service > /dev/null
		if ps -ef | grep "nginx"|egrep -v grep > /dev/null
			then
			echo 关闭Nginx失败,请手动关闭
			exit
			else
			echo 关闭Nginx和Nginx开机自启动成功!
		fi
		else
			echo 本机未安装Nginx!
	fi

	if ps -ef | grep "httpd"|egrep -v grep > /dev/null
		then
			echo 正在关闭Apache和Apache开机自启动
			update-rc.d  -f  my_servd  remove > /dev/null
			/etc/init.d/httpd stop > /dev/null
			systemctl stop httpd.service > /dev/null
			if ps -ef | grep "httpd"|egrep -v grep > /dev/null
				then
				echo 关闭Apache失败,请手动关闭
				exit
				else
				echo 关闭Apache和Apache开机自启动成功!
			fi
		else
			echo 本机未安装Apache!
	fi
	}

echo "正在安装wget,supervisor,firewalld"
apt update
apt-get -y wget supervisor firewalld
echo "正在配置supervisor"
apt-get -y install supervisor
systemctl enable supervisor
systemctl start supervisor
cd /etc/supervisor/conf.d
wget http://download.e4y.icu/frps.conf
mkdir /home/frps
cd /home/frps
wget http://download.e4y.icu/frps
wget http://download.e4y.icu/frps.ini
read -p "正在配置探针,请输入管理密码 > " dashboard_pwd
read -p "请输入Frp Token 特权密码 > " token
read -p "请输入节点 ID > " id
echo "管理密码 = $dashboard_pwd"
echo "Frp Token 特权密码 = $token"
echo "节点 ID = $id"
sleep 3s
sed -i 's/mtLwLsouVGXoCRtZ/'$1'/g' frps.ini
sed -i 's/bjouQXnmNTnWCXmm/'$2'/g' frps.ini
sed -i 's/OCDekBsSnumfwRqc/'$3'/g' frps.ini
chmod 777 -R /home/frps
supervisorctl reread
supervisorctl update
supervisorctl restart frps
echo "正在配置防火墙"
apt-get -y install firewalld
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --zone=public --add-port=1-65535/udp --permanent
firewall-cmd --zone=public --add-port=1-65535/tcp --permanent
firewall-cmd --reload
read -p "正在配置探针,请输入密钥 > " Key
curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh install_agent api.tinyfrp.ml 5555 $Key
echo "密钥 = $Key"
echo "配置完成"
echo "管理密码 = $dashboard_pwd"
echo "Frp Token 特权密码 = $token"
echo "节点 ID = $id"

function update {
cd /home/frps
rm -f  frps
wget http://download.e4y.icu/frps
sed -i 's/https:\/\/api.openfrp.net\//https:\/\/of-dev-api.bfsea.xyz\/api\//g' frps.ini
chmod 777 -R /home/frps
supervisorctl reread
supervisorctl update
supervisorctl restart frps
}

function forkey {
printf "输入1为国外节点,2为国内节点: "
read tokey
case $tokey in
    1)
        echo "1"
        ;;
    2)
        echo "2"
        ;;
    *)
        echo "请重新输入范围内的数字"
esac
}
function other {
	echo "3"
}
select option in "添加新节点" "更新节点" "更改为密钥登陆" "其他" "退出"
do 
	case $option in
	"退出")
        break ;;
	"添加新节点")
        newnode  ;;
	"更新节点")
		update ;;
	"更改为密钥登陆")
		forkey ;;
	"其他")
		other ;;
	*)
		echo "请重新输入范围内的数字" ;;
	esac
done