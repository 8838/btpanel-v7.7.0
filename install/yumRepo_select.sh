#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
get_Yum_Repo(){
	nodes=(http://mirrors.cloud.tencent.com/repo/centos7_base.repo http://mirrors.aliyun.com/repo/Centos-7.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo https://mirrors.tuna.tsinghua.edu.cn/help/centos/index.html)
	i=1
	for node in ${nodes[@]}; 
	do
		start=$(date +%s.%N)
		result=$(curl --connect-timeout 5 --head -s -o /dev/null -w %{http_code} ${node})
		if [ "$result" == "200" ];then
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
		yumRepo='False';
		T_HOST='False'
	else
		mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.Bak 
		yumRepo=${urls[$j]}
		my_tmp=$(echo $yumRepo|grep 'tencent')
		if [ "$my_tmp" ];then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
		elif [ $(echo $yumRepo|grep 'aliyun') ]; then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
		elif [ $(echo $yumRepo|grep '163') ];then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
		elif [ $(echo $yumRepo|grep 'tsinghua') ];then
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://download.bt.cn/mirrors/repo/Centos7-Base-thu.repo
		fi
		yum makecache
	fi
}
centos_version=$(cat /etc/redhat-release | grep ' 7.' | grep -i centos)
if [ "${centos_version}" ];then
	get_Yum_Repo
fi

