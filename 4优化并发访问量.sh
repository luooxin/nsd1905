#!/bin/bash
#优化并发访问量
conf="/usr/local/nginx/conf"
nh=`lscpu | awk '/CPU.s.:/{print $2}'`
sed -i "s/worker_processes  1;/worker_processes  $nh;/" $conf/nginx.conf
sed -i 's/worker_connections  1024;/worker_connections  65535;/'  $conf/nginx.conf
ulimit -Hn 100000
ulimit -Sn 100000
sed -i '1a*  soft nofile  100000\n*  hard nofile 100000'  /etc/security/limits.conf
sed -i '/http {/aclient_header_buffer_size 1k;\nlarge_client_header_buffers 4 4k;'  $conf/nginx.conf
