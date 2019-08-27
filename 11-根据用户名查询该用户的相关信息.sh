#! /bin/bash
# Function：根据用户名查询该用户的所有信息
read -p "请输入要查询的用户名：" A
echo "------------------------------"
n=`cat /etc/passwd | awk -F: '$1~/^'$A'$/{print}' | wc -l`
if [ $n -eq 0 ];then
echo -e "\033[31m该用户不存在\033[0m"
echo "------------------------------"
else
  echo -e "\033[34m该用户的用户名：$A\033[0m"
  echo -e "\033[34m该用户的UID：`cat /etc/passwd | awk -F: '$1~/^'$A'$/{print}'|awk -F: '{print $3}'`\033[0m"
  echo -e "\033[34m该用户的组为：`id $A | awk {'print $3'}`\033[0m"
  echo -e "\033[34m该用户的GID为：`cat /etc/passwd | awk -F: '$1~/^'$A'$/{print}'|awk -F: '{print $4}'`\033[0m"
  echo -e "\033[34m该用户的家目录为：`cat /etc/passwd | awk -F: '$1~/^'$A'$/{print}'|awk -F: '{print $6}'`\033[0m"
  Login=`cat /etc/passwd | awk -F: '$1~/^'$A'$/{print}'|awk -F: '{print $7}'`
  if [ $Login == "/bin/bash" ];then
  echo -e "\033[34m该用户有登录系统的权限！！\033[0m"
  echo "------------------------------"
  elif [ $Login == "/sbin/nologin" ];then
  echo -e "\033[34m该用户没有登录系统的权限！！\033[0m"
  echo "------------------------------"
  fi
fi

