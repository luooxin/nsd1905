#!/bin/bash
checkyum(){
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
        exit
fi
}

checkrjb(){
app="nginx-1.12.2.tar.gz zabbix-3.4.4.tar.gz "
for i in $app
do  
if  [ ! -f $i ];then 
echo -e "\033[31m未找到$i脚本结束运行\033[0m"
fi
done 
}

startlnmp(){
tar -xf nginx-1.12.2.tar.gz
yum -y install gcc pcre-devel openssl-devel  &> /dev/null
echo -e "\033[31m已安装源码编译依赖包\033[0m"
yum -y install php php-fpm php-mysql &> /dev/null
systemctl restart php-fpm
systemctl enable php-fpm &> /dev/null
echo -e "\033[31m已部署php服务\033[0m"
cd nginx-1.12.2
./configure --with-http_ssl_module --with-stream --with-http_stub_status_module  &> /dev/null
make   &> /dev/null
make install  &> /dev/null
echo -e "\033[31mnginx源码编译安装成功\033[0m"
conf="/usr/local/nginx/conf"
sed -i '65,71s/#//' $conf/nginx.conf
sed -i '/SCRIPT_FILENAME/d'  $conf/nginx.conf
sed -i 's/fastcgi_params/fastcgi.conf/'  $conf/nginx.conf
/usr/local/nginx/sbin/nginx
echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.local
chmod +x /etc/rc.local
cd ..
}

mariadbserver (){
yum -y install mariadb mariadb-server mariadb-devel &> /dev/null
systemctl restart mariadb
systemctl enable mariadb  &> /dev/null
echo -e "\033[31m已部署数据库服务\033[0m"
ss -nutpl | egrep :3306
if [ $? -ne 0 ];then
echo "\033[31mmariadb服务启动失败\033[0m"
fi
}

startzabbix(){
yum -y install net-snmp-devel curl-devel libevent-devel &> /dev/null
tar -xf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4/
./configure --enable-server --enable-proxy --enable-agent --with-mysql=/usr/bin/mysql_config --with-net-snmp --with-libcurl
make install
echo -e "\033[31mzabbix源码编译完成\033[0m"
cd ..
}

createuser(){
mysql -e "create database zabbix character set utf8"
mysql -e "grant all on zabbix.* to zabbix@"localhost" identified by 'zabbix'"
cd zabbix-3.4.4/database/mysql
mysql -uzabbix -pzabbix zabbix < schema.sql
mysql -uzabbix -pzabbix zabbix < images.sql
mysql -uzabbix -pzabbix zabbix < data.sql
cd ..
cd ..
cd ..
}

upzabbixphp(){
cd zabbix-3.4.4/frontends/php/
cp -a * /usr/local/nginx/html/
chmod -R 777 /usr/local/nginx/html/*
sed -i "/^http {/afastcgi_buffers 8 16k;\nfastcgi_buffer_size 32k;\nfastcgi_connect_timeout 300;\nfastcgi_send_timeout 300;\nfastcgi_read_timeout 300;"  /usr/local/nginx/conf/nginx.conf
yum -y install php-bcmath php-mbstring php-gd php-xml php-ldap
sed -i '/^;date.timezone/s\;date.timezone =\date.timezone =Asia/Shanghai\' /etc/php.ini
sed -i '/^max_exe/s/30/300/' /etc/php.ini
sed -i '/^post_max/s/8M/32M/' /etc/php.ini
sed -i '/^max_input_time/s/60/300/' /etc/php.ini
systemctl restart php-fpm
/usr/local/nginx/sbin/nginx -s reload
}

confmariadb(){
a
}

##############################################################################################
echo "执行该脚本需要准备可用yum源及nginx-1.12.2.tar.gz、zabbix-3.4.4.tar.gz"
read -p "是否需要继续执行该脚本[y/n]" n
if [ $n == "y" ];then
checkyum
checkrjb
startlnmp
mariadbserver
startzabbix
createuser
upzabbixphp
echo "准备进入网页注册"
sleep 5
read -p "请输入本机IP地址:" z
firefox $z/index.php
else
exit
fi
