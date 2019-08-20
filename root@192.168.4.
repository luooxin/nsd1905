#!/bin/bash
#nginx服务器
checkyum(){
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
        exit
fi
}

checklnmptar(){
tar -xf lnmp_soft.tar.gz  &> /dev/null
if [ $? -ne 0 ];then
     echo -e "\033[31m未找到lnmp_soft.tar.gz或不存在\033[0m"
     exit
fi
}

Compileandinstall(){
cd lnmp_soft
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2
yum -y install gcc pcre-devel openssl-devel  &> /dev/null
echo -e "\033[31m已安装源码编译依赖包\033[0m"
yum -y install mariadb mariadb-server mariadb-devel &> /dev/null
systemctl restart mariadb
systemctl enable mariadb  &> /dev/null
echo -e "\033[31m已部署数据库服务\033[0m"
yum -y install php php-fpm php-mysql &> /dev/null
systemctl restart php-fpm
systemctl enable php-fpm &> /dev/null
echo -e "\033[31m已部署php服务\033[0m"
./configure --with-http_ssl_module --with-stream --with-http_stub_status_module  &> /dev/null
make   &> /dev/null
make install  &> /dev/null
echo -e "\033[31mnginx源码编译安装成功\033[0m"
}

configure(){
conf="/usr/local/nginx/conf"
sed -i '65,71s/#//' $conf/nginx.conf
sed -i '/SCRIPT_FILENAME/d'  $conf/nginx.conf
sed -i 's/fastcgi_params/fastcgi.conf/'  $conf/nginx.conf
}

checkyum
checklnmptar
Compileandinstall
configure
/usr/local/nginx/sbin/nginx  &> /dev/null
ss -nutpl | grep :80   &> /dev/null
if [ $? -ne 0 ];then
   echo -e "\033[31m脚本执行错误,服务启动失败\033[0m"
   echo "报错信息`/usr/local/nginx/sbin/nginx`"
   exit
else
   echo -e "\033[31m脚本执行成功,nginx已启动\033[0m"
fi
