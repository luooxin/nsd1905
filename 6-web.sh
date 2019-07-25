#!/bin/bash
#部署LVS-DR集群
#服务器
cd /etc/sysconfig/network-scripts/
cp ifcfg-lo{,:0}
sed -i '/^DEV/s/lo/lo:0/' ifcfg-lo:0
yip=`awk -F= '/^IPADDR/{print $2}' ifcfg-lo:0`
read -p "请输入VIP地址:" VIP
sed -i "/^IPADDR/s/$yip/$VIP/" ifcfg-lo:0
sed -i '/^NETMASK/s/255.0.0.0/255.255.255.255/' ifcfg-lo:0
sed -i "/^NETWORK/s/127.0.0.0/$VIP/" ifcfg-lo:0
sed -i "/^BROADC/s/127.255.255.255/$VIP/" ifcfg-lo:0
sed -i '/^NAME/s/loopback/lo:0/' ifcfg-lo:0
sed -i '/For/anet.ipv4.conf.all.arp_ignore = 1\nnet.ipv4.conf.lo.arp_ignore = 1\nnet.ipv4.conf.lo.arp_announce = 2\nnet.ipv4.conf.all.arp_announce = 2' /etc/sysctl.conf
sysctl -p
systemctl restart network
