#!/bin/bash
#部署TCP/UDP调度器
checkyum(){
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
	exit
fi
}

checknginx(){
if [ ! -f nginx-1.12.2.tar.gz ];then
echo -e "\033[31m未找到nginx源码包,脚本结束运行\033[0m"
exit
fi
}

nginxaz(){
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2
yum -y install gcc pcre-devel openssl-devel  &> /dev/null
echo -e "\033[31m已安装源码编译依赖包\033[0m"
./configure --with-http_ssl_module --with-stream --with-http_stub_status_module  &> /dev/null
make   &> /dev/null
make install  &> /dev/null
echo -e "\033[31mnginx源码编译安装成功\033[0m"
}

gaipeizhi(){
conf="/usr/local/nginx/conf"
sed -i '/http {/istream {' $conf/nginx.conf
for i in {1..100}
do
read -p "请输入一个服务器的ip地址(空为结束):" ip
echo $ip  >> ipdizhiwenjian.txt
if [ -z "$ip" ];then
  break
fi
done
sed -i '/stream {/aupstream backend {\n}'  $conf/nginx.conf
for h in `cat ipdizhiwenjian.txt`
do
sed -i "/backend/aserver $h:22;" $conf/nginx.conf
done
rm -rf ipdizhiwenjian.txt
sed -i '/http {/iserver {\nlisten 12345;\nproxy_connect_timeout 60s;\nproxy_timeout 60s;\nproxy_pass backend;\n}\n}'  $conf/nginx.conf
}

###############################################################################################
echo "执行该脚本需要准备可用yum源及nginx-1.12.2.tar.gz"
read -p "是否需要继续执行该脚本[y/n]" n
if [ $n == "y" ];then
checkyum
checknginx
nginxaz
gaipeizhi
fi
