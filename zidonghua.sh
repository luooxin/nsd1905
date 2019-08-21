#!/bin/bash
ready(){
for a in {1..100}
do
read -p "请输入集群服务器的ip地址(空为结束):" ip
echo $ip  >> ipdizhiwenjian.txt
if [ -z "$ip" ];then
  break
fi
done
}

ssh(){
ssh-keygen  -f /root/.ssh/id_rsa  -N ''
for e in `cat ipdizhiwenjian.txt`
do
ssh-copy-id $e
done
}

package(){
mkdir asdfg
for d in {1..100}
do
read -p "请输入安装软件包绝对路径(空为结束)" b
cp -r $b asdfg/
if [ -z "$b" ];then
  break
fi
done
for c in `cat ipdizhiwenjian.txt`
do
scp -r asdfg $c:/root
done
}

###########################################################################################
ready
read -p "是否需要执行密匙分发[y/n]" f
if [ $f == "y" ];then
ssh
fi
package
