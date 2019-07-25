#!/bin/bash
#部署LVS集群
#调度器
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
        exit
fi
yum -y install ipvsadm
cd /etc/sysconfig/network-scripts/
cp ifcfg-eth0{,:0}
sed -i '/^NAME/s/eth0/eth0:0/' ifcfg-eth0:0
sed -i '/^DEVICE/s/eth0/eth0:0/'  ifcfg-eth0:0
yip=`awk -F= '/^IPADDR/{print $2}' ifcfg-eth0:0`
read -p "请输入VIP地址:" vip
sed -i "/^IPADDR/s/$yip/$vip/" ifcfg-eth0:0
sed -i '/UUID/d' ifcfg-eth0:0
systemctl stop NerworkManager
systemctl restart network
systemctl restart NerworkManager
ipvsadm -C
read -p "请输入集群协议(t|u):" xy
read -p "请输入集群算法(rr|wrr|lc|wlc):" jq
read -p "请输入DIP:端口号:" DIP
ipvsadm -A -$xy $DIP -s $jq
read -p "请输入web服务器1RIP地址:" RIP1
read -p "请输入web服务器2RIP地址:" RIP2
read -p "请输入轮询次数:" lx
read -p "请输入服务器工作模式(m|g|i):" ms
ipvsadm -a -$xy $DIP -r $RIP1 -w $lx -$ms
ipvsadm -a -$xy $DIP -r $RIP2 -w $lx -$ms
ipvsadm-save -n > /etc/sysconfig/ipvsadm
grep 'net.ipv4.ip_forward' /etc/sysctl.conf
if [ $? -ne 0 ];then
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
fi
