#!/bin/sh
#

##########################################
# update dnspod record
# Dynamic DNS using DNSPod API
# Original by xiaoqi <1846627226@qq.com>
# Blog by xiaoqi <https://i7dom.cn>
# Edited Date:2019/11/29
##########################################

# dnspod id token Authentication
dpId=""
dpToken=""

# domain name
dpDomain=''

# host name
dpHost=''

# device name
DEV="pppoe-wan"


# TTL
TTL='120'

# log date
logTime=$(date +"[%Y-%m-%d %H:%M]")

# ip regular 
IPREG='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

# script run dir
DIRNAME=$(pwd)

# user-agent
AGENT='ddns update script/1.0'

# Get device ip
DEVIP=$(ifconfig $DEV | grep -Eo "$IPREG" | head -n1 )

if (echo $DEVIP | grep -qEvo "$IPREG");then
    echo "$logTime [error]: get $DEV ip failed!" >> $DIRNAME/ddns.log
    exit 1    
fi

echo "$logTime [info]: Get device ip: $DEVIP" >> $DIRNAME/ddns.log

#查询记录是否存在,
LISTURL='https://dnsapi.cn/Record.List'
LISTPARMS="login_token=$dpId,$dpToken&format=json&domain=$dpDomain&sub_domain=$dpHost&record_type=A"
RESPONSE=$(curl  -k -A "$AGENT" -X POST "$LISTURL" -d $LISTPARMS)

if [ "$?" != 0 ]||(echo $RESPONSE | grep -qEvo "successful");then
    echo "$logTime [warning]: dnspod not $dpHost record" >> $DIRNAME/ddns.log
fi

echo "$RESPONSE" > $DIRNAME/ddns.info

#增加空记录
ADDURL='https://dnsapi.cn/Record.Create'
ADDPARMS="login_token=$dpId,$dpToken&format=json&domain=$dpDomain&sub_domain=$dpHost&record_type=A&record_line=默认&value=127.0.0.1&ttl=$TTL"
CODE=$(jq '.status.code' $DIRNAME/ddns.info)

#添加一条记录跟新需要record_id
if [  "$CODE" == '"10"' ];then
    echo "$logTime [warning]: add dns record" >> $DIRNAME/ddns.log
    ADDRESPONSE=$(curl -k -A "$AGENT" -X POST "$ADDURL" -d $ADDPARMS)
    echo "$ADDRESPONSE" > $DIRNAME/ddns.info
    CODE=$(jq '.status.code' $DIRNAME/ddns.info)
    if [ "$CODE" == '"1"' ];then
        echo "$logTime [warning]: add dns record success " >> $DIRNAME/ddns.log
    fi
fi

#更新记录
DIFFURL1='https://dnsapi.cn/Record.List'
DIFFPARMS="login_token=$dpId,$dpToken&format=json&domain=$dpDomain&sub_domain=$dpHost&record_type=A"
RESPONSE=$(curl -k -A "$AGENT" -X POST "$DIFFURL1" -d $DIFFPARMS)
echo $RESPONSE > $DIRNAME/ddns.info
OLDIP=$(jq .records[0].value $DIRNAME/ddns.info | sed 's/\"//g')
OLDLINE=$(jq .records[0].line $DIRNAME/ddns.info | sed 's/\"//g')
OLDID=$(jq .records[0].id $DIRNAME/ddns.info | sed 's/\"//g')

UPDATEURL='https://dnsapi.cn/Record.Modify'
UPDATEPARMS="login_token=$dpId,$dpToken&format=json&domain=$dpDomain&record_id=$OLDID&sub_domain=$dpHost&record_type=A&record_line=默认&value=$DEVIP&ttl=$TTL"

echo "$logTime [info] DNS A:"$OLDIP" device ip:"$DEVIP" dns line:"$OLDLINE" record_id:"$OLDID >> $DIRNAME/ddns.log

#对比dnspod记录后跟新
if [ "$OLDIP" != "$DEVIP" ];then
    echo "$logTime [warning]: dnspod record id:$OLDID value:$OLDIP" >> $DIRNAME/ddns.log
    echo "$logTime [warning]: pppoe-wan IP:$DEVIP" >> $DIRNAME/ddns.log
    RESPONSE=$(curl -k -A "$AGENT" -X POST "$UPDATEURL" -d $UPDATEPARMS)
    echo $RESPONSE > $DIRNAME/ddns.info
    CODE=$(jq .status.code $DIRNAME/ddns.info | sed 's/\"//g')
    MSG=$(jq .status.message $DIRNAME/ddns.info | sed 's/\"//g')
    if [ $CODE != '1' ];then
        echo "$logTime [error]: Update Failed send e-mail to xiaoqi" >> $DIRNAME/ddns.log
    else
        echo "$logTime [info]: code: $CODE message: $MSG" >> $DIRNAME/ddns.log
    fi 
else
    echo "$logTime [info]: Dns record ip:$OLDIP device ip:$DEVIP" >> $DIRNAME/ddns.log
fi 
