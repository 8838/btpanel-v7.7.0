# btpanel-v7.7.0
btpanel-v7.7.0-backup  官方原版v7.7.0版本面板备份

**Centos/Ubuntu/Debian安装命令 独立运行环境（py3.7）**

```Bash
curl -sSO https://raw.githubusercontent.com/8838/btpanel-v7.7.0/main/install/install_panel.sh && bash install_panel.sh
```

**备用安装链接，适用于不能访问GitHub的服务器。文件公开存放在[d.moe.ms](http://d.moe.ms/?btpanel-v7.7.0)**

```
curl -sSO http://d.moe.ms/AAAAA/btpanel-v7.7.0/install/install_panel.sh && bash install_panel.sh
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

该版本有一个0点CPU高占用BUG：https://www.bt.cn/bbs/thread-93986-1-1.html

文件路径：`/www/server/panel/task.py`

搜索`0000-00-00`定位

```
def siteEdate():
    global oldEdate
    try:
        if not oldEdate:
            oldEdate = ReadFile('/www/server/panel/data/edate.pl')
        if not oldEdate:
            oldEdate = '0000-00-00'
        mEdate = time.strftime('%Y-%m-%d', time.localtime())
        if oldEdate == mEdate:
            return False
        os.system(get_python_bin() +
                  " /www/server/panel/script/site_task.py > /dev/null")
    except Exception as ex:
        logging.info(ex)
        pass
```

替换为：

```
def siteEdate():
    global oldEdate
    try:
        if not oldEdate: oldEdate = ReadFile('{}/data/edate.pl'.format(base_path))
        if not oldEdate: oldEdate = '0000-00-00'
        mEdate = time.strftime('%Y-%m-%d', time.localtime())
        if oldEdate == mEdate: return False
        os.system(get_python_bin() + " {}/script/site_task.py > /dev/null".format(base_path))
    except Exception as ex:
        logging.info(ex)
        pass
```
最后重启一下面板
