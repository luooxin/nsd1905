#!/bin/bash
yum clean all &> /dev/null
yumr=`yum repolist 2> /dev/null | awk '/^repo/{print $2}' | sed 's/,//'`
if [ $yumr -eq 0 ];then
      echo -e "\033[31myum仓库不可用\033[0m"
	exit
fi
yum -y install chronyd
for i in {1..100}
do
read -p "请输入您要允许访问时间服务器的网段(空为结束):" ip
echo $ip  >> ipdizhiwenjian.txt
if [ -z "$ip" ];then
  break
fi
done
for h in `cat ipdizhiwenjian.txt`
do
sed -i "/#allow/aallow $ip/24"
done
rm -rf ipdizhiwenjian.txt
sed -i '/#local stratum 10/s/#//'
systemctl restart chronyd
systemctl enable chronyd
