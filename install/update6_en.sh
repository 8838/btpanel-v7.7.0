#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

if [ ! -d /www/server/panel/BTPanel ];then
	echo "============================================="
	echo "Error, 5.x Can't use this command to upgrade!"
	#echo "5.9 Smooth upgrade to 6.0 command：curl http://download.bt.cn/install/update_to_6.sh|bash"
	exit 0;
fi

public_file=/www/server/panel/install/public.sh
publicFileMd5=$(md5sum ${public_file} 2>/dev/null|awk '{print $1}')
md5check="918CC0E14AC92F9D51BFD5CE6A076C36"
if [ "${publicFileMd5}" != "${md5check}"  ]; then
	wget -O Tpublic.sh https://raw.githubusercontent.com/8838/btpanel-v7.7.0/main/install/public.sh -T 20;
	publicFileMd5=$(md5sum Tpublic.sh 2>/dev/null|awk '{print $1}')
	if [ "${publicFileMd5}" == "${md5check}"  ]; then
		\cp -rpa Tpublic.sh $public_file
	fi
	rm -f Tpublic.sh
fi
. $public_file

Centos8Check=$(cat /etc/redhat-release | grep ' 8.' | grep -iE 'centos|Red Hat')
if [ "${Centos8Check}" ];then
	if [ ! -f "/usr/bin/python" ] && [ -f "/usr/bin/python3" ] && [ ! -d "/www/server/panel/pyenv" ]; then
		ln -sf /usr/bin/python3 /usr/bin/python
	fi
fi

mypip="pip"
env_path=/www/server/panel/pyenv/bin/activate
if [ -f $env_path ];then
	mypip="/www/server/panel/pyenv/bin/pip"
fi

download_Url=$NODE_URL
setup_path=/www
version=$(curl -Ss --connect-timeout 5 -m 2 https://brandnew.aapanel.com/api/panel/getLatestOfficialVersion)
if [ "$version" = '' ];then
	version='6.8.16'
fi
wget -T 5 -O /tmp/panel.zip https://raw.githubusercontent.com/8838/btpanel-v7.7.0/main/install/src/LinuxPanel-7.7.0.zip
dsize=$(du -b /tmp/panel.zip|awk '{print $1}')
if [ $dsize -lt 10240 ];then
	echo "Failed to get update package, please update or contact aaPanel Operation"
	exit;
fi
unzip -o /tmp/panel.zip -d $setup_path/server/ > /dev/null
rm -f /tmp/panel.zip
cd $setup_path/server/panel/
check_bt=`cat /etc/init.d/bt`
if [ "${check_bt}" = "" ];then
	rm -f /etc/init.d/bt
	wget -O /etc/init.d/bt https://raw.githubusercontent.com/8838/btpanel-v7.7.0/main/install/src/bt6.init -T 20
	chmod +x /etc/init.d/bt
fi
rm -f /www/server/panel/*.pyc
rm -f /www/server/panel/class/*.pyc
#pip install flask_sqlalchemy
#pip install itsdangerous==0.24
pip_list=$($mypip list)
request_v=$(echo "$pip_list"|grep requests)
if [ "$request_v" = "" ];then
	$mypip install requests
fi
openssl_v=$(echo "$pip_list"|grep pyOpenSSL)
if [ "$openssl_v" = "" ];then
	$mypip install pyOpenSSL
fi

cffi_v=$(echo "$pip_list"|grep cffi|grep 1.12.)
if [ "$cffi_v" = "" ];then
	$mypip install cffi==1.12.3
fi
pymysql=$(echo "$pip_list"|grep pymysql)
if [ "$pymysql" = "" ];then
	$mypip install pymysql
fi

psutil=$(echo "$pip_list"|grep psutil|awk '{print $2}'|grep '5.7.')
if [ "$psutil" = "" ];then
	$mypip install -U psutil
fi
$mypip install telegram
$mypip install paramiko -I
Run_User="www"
groupadd ${Run_User}
useradd -s /sbin/nologin -g ${Run_User} ${Run_User}
chattr -i /etc/init.d/bt
chmod +x /etc/init.d/bt
echo "====================================="
rm -f /dev/shm/bt_sql_tips.pl
kill $(ps aux|grep -E "task.pyc|main.py"|grep -v grep|awk '{print $2}')
#/etc/init.d/bt restart
#echo 'True' > /www/server/panel/data/restart.pl
echo "Successfully upgraded to[$version]${Ver}";


