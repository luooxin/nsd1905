#!/bin/bash
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
        exit
fi
yum -y install haproxy   &> /dev/null
sed -i '/chroot/s\/var/lib/haproxy\/usr/local/haproxy.pid\' /etc/haproxy/haproxy.cfg
sed -i '63,86d'  /etc/haproxy/haproxy.cfg
read -p "请输入web1Ip地址" web1
read -p "请输入web2Ip地址" web2
sed -i "62alisten servers *:80\nbalance roundrobin\nserver web1 $web1 check inter 2000 rise 2 fall 5\nserver web1 $web2 check inter 2000 rise 2 fall 5"  /etc/haproxy/haproxy.cfg
sed -i "/$web2/alisten stats *:1080\nstats refresh 30s\nstats uri /stats\nstats realm Haproxy Manager\nstats auth admin:admin\n#stats hide-version"  /etc/haproxy/haproxy.cfg
