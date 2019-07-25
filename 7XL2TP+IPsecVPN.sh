#!/bin/bash
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
        exit
fi
yum -y install libreswan   &> /dev/null
read -p "请输入myipsec.conf的绝对路径:"  myipsec
cp $myipsec /etc/ipsec.d/myipsec.conf
read -p "请输入预定义共享密匙" miss
echo "201.1.2.10 %any: PSK "$miss"" > /etc/ipsec.d/mypass.secrets
systemctl restart ipsec
if [ ! -d lnmp_soft ];then
    echo "没有lnmp_soft这个目录,无法执行下面步骤"
fi
cd /root/lnmp_soft/vpn/
yum -y install xl2tpd-1.3.8-2.el7.x86_64.rpm  &> /dev/null
ippp=`awk -F= '/^ip range/{print $2}' /etc/xl2tpd/xl2tpd.conf`
read -p "请输入分配给客户端的IP地址池[ip-ip]:"  ipc
sed -i "/^ip range/s/$ippp/$ipc/" /etc/xl2tpd/xl2tpd.conf
ippd=`awk -F= '/^local ip/{print $2}' /etc/xl2tpd/xl2tpd.conf`
read -p "请输入VPN服务器的IP地址" ipa
sed -i "/^local ip/s/$ippd/$ipa/" /etc/xl2tpd/xl2tpd.conf
sed -i '/^# require/s/# //' /etc/ppp/options.xl2tpd
sed -i 's/^crtscts/#crtscts/' /etc/ppp/options.xl2tpd
sed -i 's/^lock/#lock/' /etc/ppp/options.xl2tpd
read -p "请输入用于登录的账号" zh
read -p "请输入用于登录的密码" mm
echo "$zh * $mm *" >> /etc/ppp/chap-secrets
systemctl start xl2tpd
