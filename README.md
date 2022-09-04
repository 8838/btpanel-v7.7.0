# btpanel-v7.7.0
btpanel-v7.7.0-backup  官方原版v7.7.0版本面板备份

**Centos/Ubuntu/Debian安装命令 独立运行环境（py3.7）**

```Bash
curl -sSO https://raw.githubusercontent.com/8838/btpanel-v7.7.0/main/install/install_panel.sh && bash install_panel.sh
```

## 手动破解：

### 1，屏蔽手机号

```
sed -i "s|bind_user == 'True'|bind_user == 'XXXX'|" /www/server/panel/BTPanel/static/js/index.js
```

### 2，直接删除宝塔强制绑定手机js文件

```
rm -f /www/server/panel/data/bind.pl
```

### 3，面板设置里暂时开启离线模式

### 4，手动解锁宝塔所有付费插件为永不过期

文件路径：www/server/panel/data/plugin.json
搜索字符串：`"endtime": -1`全部替换为`"endtime": 999999999999`

### 5，给plugin.json文件上锁防止自动修复为免费版

```
chattr +i /www/server/panel/data/plugin.json
```

### 6，上锁后现在可以关闭离线模式了

===========================================================

### ！！如需取消屏蔽手机号
```
sed -i "s|if (bind_user == 'REMOVED') {|if (bind_user == 'True') {|g" /www/server/panel/BTPanel/static/js/index.js
```
