#!/bin/bash
#快速部署nginx调度器
#未附加权重功能
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
      exit
fi
tar -xf lnmp_soft.tar.gz  &> /dev/null
if [ $? -ne 0 ];then
     echo -e "\033[31m未找到lnmp_soft.tar.gz或不存在\033[0m"
     exit
fi
cd lnmp_soft
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2
yum -y install gcc pcre-devel openssl-devel  &> /dev/null
echo -e "\033[31m已安装源码编译依赖包\033[0m"
#yum -y install mariadb mariadb-server mariadb-devel &> /dev/null
#systemctl restart mariadb
#systemctl enable mariadb  &> /dev/null
#echo -e "\033[31m已部署数据库服务\033[0m"
#yum -y install php php-fpm php-mysql &> /dev/null
#systemctl restart php-fpm
#systemctl enable php-fpm &> /dev/null
#echo -e "\033[31m已部署php服务\033[0m"
./configure --with-http_ssl_module --with-stream --with-http_stub_status_module  &> /dev/null
make   &> /dev/null
make install  &> /dev/null
echo -e "\033[31mnginx源码编译安装成功\033[0m"
conf="/usr/local/nginx/conf"
for i in {1..100}
do
read -p "请输入一个服务器的ip地址(空为结束):" ip
echo $ip  >> ipdizhiwenjian.txt
if [ -z "$ip" ];then
  break
fi
done
sed -i '/#gzip/aupstream webs {\n}'  $conf/nginx.conf
for h in `cat ipdizhiwenjian.txt`
do
sed -i "/upstream/aserver $h:80;" $conf/nginx.conf
done
rm -rf ipdizhiwenjian.txt
sed -i '/#charset/iproxy_pass http://webs;' $conf/nginx.conf
for sj in {5..1}
do
sleep 1
echo -ne "\b\b$sj"
done

