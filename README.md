# DDNS

> 使用脚本更新DNSpod的DNS解析到本机IP,目前仅支持解析A记录(ipv4).支持本机IP和外网IP解析.


# 依赖

此脚本依赖的依赖程序:`git`,`curl`,`jq`.

- 依赖安装方式:

```bash
#CentOS
yum install git jq curl

#Ubuntu
sudo apt-get install git jq curl
```
> 如果无法正常安装`jq`则可以到<https://stedolan.github.io/jq/download/>下载已经编译好的`jq`复制到`/bin/`目录下

# 使用

- 关于`DNSPod`的`token`申请参考官网或者百度,这里就不写详细申请方式!

```bash
dnspod-record.sh  这个脚本是直接获取wan口的IP进行跟新

net-dnspod-record.sh  这个脚本则是获取外网IP后使用外网IP进行更新记录
```

- 配置方法

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

# TTL
TTL='120' #记录的TTL值,如果是普通用户默认应该是600,我买了解析所以我是120

```
> `net-dnspod-record.sh`这个脚本是没有`DEV=`这个参数的,可以不用加

- 使用方法

```bash
#克隆这个库
git clone https://github.com/xiaoicx/ddns-dnspod-script.git

cd ddns-dnspod-script

chmod +x *

./dnspod-record.sh 或 ./net-dnspod-record.sh
```

- 定时执行

```bash
crontab -e

#五分钟执行一次
*/5 * * * * /root/dnspod-record.sh
```

# FQA

> 有问题可以到我博客留言或者发邮件给我:blog <https:i7dom.cn> email <onxiaoqi@qq.com >