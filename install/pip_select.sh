#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
pyenv_bin=/www/server/panel/pyenv/bin
rep_path=${pyenv_bin}:$PATH
if [ -d "$pyenv_bin" ];then
	PATH=$rep_path
fi
export PATH
LANG=en_US.UTF-8
get_PIP_URL(){
	nodes=(https://mirrors.tencent.com/pypi/simple https://pypi.doubanio.com/simple https://mirrors.aliyun.com/pypi/simple https://pypi.tuna.tsinghua.edu.cn/simple https://pypi.org/simple);
	i=1;
	for node in ${nodes[@]};
	do
		start=`date +%s.%N`
		result=`curl -sS --connect-timeout 3 -m 60 $node/0/|grep Links`
		if [ "$result" != '' ];then
			end=`date +%s.%N`
			start_s=`echo $start | cut -d '.' -f 1`
			start_ns=`echo $start | cut -d '.' -f 2`
			end_s=`echo $end | cut -d '.' -f 1`
			end_ns=`echo $end | cut -d '.' -f 2`
			time_micro=$(( (10#$end_s-10#$start_s)*1000000 + (10#$end_ns/1000 - 10#$start_ns/1000) ))
			time_ms=$(($time_micro/1000))
			values[$i]=$time_ms;
			urls[$time_ms]=$node
			i=$(($i+1))
			if [ $time_ms -lt 50 ];then
				break;
			fi
		fi
	done
	j=5000
	for n in ${values[@]};
	do
		if [ $j -gt $n ];then
			j=$n
		fi
		if [ $j -lt 50 ];then
			break;
		fi
	done
	if [ $j = 5000 ];then
		PIP_URL='False';
		T_HOST='False'
	else
		PIP_URL=${urls[$j]}
		my_tmp=$(echo $PIP_URL|grep 'aliyun')
		if [ "$my_tmp" != "" ];then
			T_HOST=mirrors.aliyun.com
		elif [ $(echo $PIP_URL|grep 'tencent') != "" ];then
			T_HOST=mirrors.tencent.com
		elif [ $(echo $PIP_URL|grep 'doubanio') != "" ];then
			T_HOST=pypi.doubanio.com
		elif [ $(echo $PIP_URL|grep 'tsinghua') != "" ];then
			T_HOST=pypi.tuna.tsinghua.edu.cn
		elif [ $(echo $PIP_URL|grep 'pypi.org') != "" ];then
			T_HOST=pypi.org
		fi
	fi
}

get_PIP_URL
if [ "$PIP_URL" != "False" ];then
	echo "$PIP_URL"
	if [ ! -d ~/.pip ];then
		mkdir -p ~/.pip
	fi
	cat > ~/.pip/pip.conf <<EOF
[global]
index-url = $PIP_URL

[install]
trusted-host = $T_HOST
EOF
else
	rm -f ~/.pip/pip.conf
fi
