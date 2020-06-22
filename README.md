# DDNS

> 使用脚本更新DNSpod的DNS解析到本机IP,目前仅支持解析A记录(ipv4).支持本机IP和外网IP解析.


# 依赖

此脚本依赖的依赖程序:`git`,`curl`,`jq`.

- 依赖安装方式:

```bash
#CentOS
yum install -y git jq curl

#Ubuntu
sudo apt-get install -y git jq curl
```
> 如果无法正常安装`jq`则可以到<https://stedolan.github.io/jq/download/>下载已经编译好的`jq`复制到`/bin/`目录下

# 使用

- 关于`DNSPod`的`token`申请参考官网或者百度,这里就不写详细申请方式!
- 重构了一次版本`v1.2`更新功能如下:

1. 优化写法使用面向过程写法
2. 注释更加详细了
3. 外网IP与网卡接口IP合并了,现在脚本支持`ip-api`和获取网卡`ip`两种方式更新
4. 使用`bash`做为解释器
5. 增加了两个IP获取接口

```bash
dnspod-record-v1.2.sh #新脚本功能多了也跟简洁了
```

- **配置方法**

```bash
# dnspod id token Authentication
dpId="" #DNSpod的ID
dpToken="" #DNSpod的token

# domain name
dpDomain='' #域名不要加主机名例如:ab.com

# host name
dpHost='' #主机名,只需要写主机名例如:www

# device name
DEV="pppoe-wan" #网卡名,可以使用ifconfig查看网卡名然后写上去

#Updata module
updataModule=1 #更新方式;0: 获取网卡IP更新 1: 使用在线ip更新

# TTL
TTL='120' #记录的TTL值,如果是普通用户默认应该是600,我买了解析所以我是120

```

> 切换ip接口:

```bash
#在main函数中修改
# getInetIP # 此项是使用淘宝的ip获取接口,就是有点慢
getInetIpI # 默认使用的ip-api接口,如果需要使用淘宝的接口则注释这行打开上面这个就行
```


- **使用方法**

```bash
#克隆这个库
git clone https://github.com/xiaoicx/ddns-dnspod-script.git

cd ddns-dnspod-script

chmod +x *

./dnspod-record-v1.2.sh
```

- **定时执行**

```bash
crontab -e

#五分钟执行一次
*/5 * * * * /root/dnspod-record-v1.2.sh
```

# FQA

> 有问题可以到我博客留言或者发邮件给我:blog <https://i7dom.cn> email <onxiaoqi@qq.com >
