# btpanel-v7.7.0
btpanel-v7.7.0-backup  官方原版v7.7.0版本面板备份

**Centos/Ubuntu/Debian安装命令 独立运行环境（py3.7）**

```Bash
curl -sSO https://raw.githubusercontent.com/8838/btpanel-v7.7.0/main/install/install_panel.sh && bash install_panel.sh
```

# 手动破解：

1，屏蔽手机号

```
sed -i "s|bind_user == 'True'|bind_user == 'XXXX'|" /www/server/panel/BTPanel/static/js/index.js
```

2，删除强制绑定手机js文件

```
rm -f /www/server/panel/data/bind.pl
```

3，手动解锁宝塔所有付费插件为永不过期

文件路径：`/www/server/panel/data/plugin.json`

搜索字符串：`"endtime": -1`全部替换为`"endtime": 999999999999`

4，给plugin.json文件上锁防止自动修复为免费版

```
chattr +i /www/server/panel/data/plugin.json
```

============================

！！如需取消屏蔽手机号
```
sed -i "s|if (bind_user == 'REMOVED') {|if (bind_user == 'True') {|g" /www/server/panel/BTPanel/static/js/index.js
```

# BUG修复

这个版本有一个官方bug，每日0点CPU高占用：https://hostloc.com/thread-1030797-1-1.html

解决办法，编辑`/www/server/panel/task.py`这个文件

```
 def siteEdate():
     global oldEdate
     try:
        if not oldEdate:       //删除这行
            oldEdate = ReadFile('/www/server/panel/data/edate.pl')
         if not oldEdate:
             oldEdate = '0000-00-00'
         mEdate = time.strftime('%Y-%m-%d', time.localtime())
```

保存，然后重启Nginx
