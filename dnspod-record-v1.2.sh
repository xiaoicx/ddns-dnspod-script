#!/bin/bash

##########################################
# update dnspod record v1.2
# Dynamic DNS using DNSPod API
# Original by xiaoqi <1846627226@qq.com>
# Blog by xiaoqi <https://i7dom.cn>
# Edited Date: 2020/06/22
# Updata Date: 2020/06/22
##########################################

#dnspod Id and Token
dpID=''
dpToken=''

#domain name
dpDomain='baidu.cn'

#host name
dpHostName='mq'

#interface name
DevName='eth0'

#TTL Value
TTL='120'

#Updata module
updataModule=1

#url
CURLHOST="https://i7dom.cn/awe/doip.php"

#log format 
logTime=$(date +"[%Y-%m-%d %H:%M]")

#updata iP
updataIP='127.0.0.1'

#LocalIP regular
ipReg='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'

#Curl user Agent
curlAgent='ddns updatee script/1.2'

#Log store directory
logDir="/var/log/ddns-record.log"
tempFile="/tmp/curl-result.dat"

#privite variable
oldIp=""
recordId=""

#写出格式化日志信息
# 参数一: 日志信息
# 参数二: 日志级别
# 参数三: 错误位置 
# 参数四: 显示错误信息
formatLogWrite(){
  
    #判断目录 && 创建目录
    if [ ! -e ${logDir} ];then
      touch ${logDir}

    #目录是否可写
    elif [ ! -w ${logDir} ];then 
      echo -e "\033[41;37m Error \033[0m 文件不可写:'chmod +x /var/log/ddns-record.log'"
      exit 1
    elif [ $4 -eq 1 ];then
      #显示错误
      echo -e "\033[41;37m Error \033[0m $1: $3"
    fi

    # 写出格式化日志
    Info="${logTime} $2 $1 ($3)"
    echo ${Info} >> ${logDir}
}

#获取本机网卡IP
getLocalIP () {

    #获取本机DevName IP
    updataIP=$(ifconfig ${DevName} | grep inet | head -n 1 | awk '{print $2}')

    #判断ip是否正确
    if [ $? -ne 0 ];then
      logInfo="ip获取错误"
      formatLogWrite $logInfo error getLocalIP 0
      exit 1
    elif [ ! ${updataIP} ];then
      logInfo="ip为空"
      formatLogWrite $logInfo error getLocalIP 0
      exit 1
    fi

    #写出info日志
    formatLogWrite ${updataIP} info getLocalIP 0
}

#获取外网IP(淘宝IP查询)
getInetIpM () {
    #返回的是Json数据
    resultJson=$(curl -k -A "${curlAgent}" -X GET "${CURLHOST}")
    #解析Json获取IP
    inetIP=$(echo ${resultJson} | jq ".ips.clientIP")
    updataIP=${inetIP//\"/}

    #检查获取的IP
    checkIP=$(echo ${updataIP} | grep -Eo "${ipReg}")
    if [ $? -ne 0 ];then
      logInfo="ip获取错误"
      formatLogWrite "$logInfo" error getInetIP 1
    fi

    #写出info日志
    formatLogWrite "${checkIP}" info getInetIP 0
}

#获取外网IP(ip-api)
getInetIpI () {

    #淘宝IP库地址
    curlHost="http://ip-api.com/json/?lang=zh-CN"

    #返回的是Json数据
    resultJson=$(curl -k -A "${curlAgent}" "${curlHost}")
    #解析Json获取IP
    inetIP=$(echo ${resultJson} | jq ".query")
    updataIP=${inetIP//\"/}

    #检查获取的IP
    checkIP=$(echo ${updataIP} | grep -Eo "${ipReg}")
    if [ $? -ne 0 ];then
      logInfo="ip获取错误"
      formatLogWrite "$logInfo" error getInetIP 1
    fi

    #写出info日志
    formatLogWrite "${checkIP}" info getInetIP 0
}


#判断dnspod记录是否存在,0:true 1:false
# return 0|1 
isDnspodRecord(){

    #提交地址与参数
    curlHost="https://dnsapi.cn/Record.List"
    postArg="login_token=${dpID},${dpToken}&format=json&domain=${dpDomain}&sub_domain=${dpHostName}&record_type=A"

    #解析Json
    resultJson=$(curl -k -A "${curlAgent}" -X POST "${curlHost}" -d "${postArg}")
    Code=$(echo ${resultJson} | jq ".status.code")
    statusCode=${Code//\"/}

    if [ ${statusCode} -eq 1 ]; then
      return 0;
    else
      return 1;
    fi
}

#创建一条空记录,0:true 1:false
#return 0|1
createDnspodRecord (){

  #提交地址与参数
  curlHost="https://dnsapi.cn/Record.Create"
  postArg="login_token=${dpID},${dpToken}&format=json&domain=${dpDomain}&sub_domain=${dpHostName}&record_type=A&record_line=默认&value=127.0.0.1&ttl=${TTL}"

  #解析Json
  resultJson=$(curl -k -A "${curlAgent}" -X POST "${curlHost}" -d "${postArg}")

  Code=$(echo "${resultJson}" | jq ".status.code")
  id=$(echo "${resultJson}" | jq ".record.id")
  statusCode=${Code//\"/}
  recordId=${id//\"/}

  #判断解析结果
  if [ ${statusCode} -eq 1 ]; then
    logInfo="记录创建成功"
    formatLogWrite $logInfo info createDnspodRecord 0
     return 0
  elif [ ${statusCode} -eq 104 ];then
    logInfo="记录已存在"
    formatLogWrite $logInfo warning createDnspodRecord 0
    return 1;
  else
    logInfo="记录创建错误"
    formatLogWrite $logInfo error createDnspodRecord 0
    exit 1
  fi 
}

#获取dnspod记录中的IP
#return ip
getDnspodRecordToIP (){

    #提交地址与参数
    curlHost="https://dnsapi.cn/Record.List"
    postArg="login_token=${dpID},${dpToken}&format=json&domain=${dpDomain}&sub_domain=${dpHostName}&record_type=A"

    #解析Json
    resultJson=$(curl -k -A "${curlAgent}" -X POST "${curlHost}" -d "${postArg}")
    ip=$(echo "${resultJson}" | jq ".records[0].value")
    id=$(echo "${resultJson}" | jq ".records[0].id")
    
    if [ -z "${ip}" ] || [ -z "${id}" ]; then
      logInfo="获取记录Ip或Id错误"
      formatLogWrite $logInfo error getDnspodRecordToIP 1
      exit 1
    fi
    
    #全局
    oldIp=${ip//\"/}
    recordId=${id//\"/}
}

#更新dnspod中的记录
# 参数一: updataIp
# 参数二: recordId
# return 0|1
updataDnspodRecordIp (){

    #提交地址与参数
    curlHost="https://dnsapi.cn/Record.Modify"
    postArg="login_token=${dpID},${dpToken}&format=json&domain=${dpDomain}&record_id=${2}&sub_domain=${dpHostName}&value=${1}&record_type=A&record_line=默认&ttl=${TTL}"

    #解析Json
    resultJson=$(curl -k -A "${curlAgent}" -X POST "${curlHost}" -d "${postArg}")
    Code=$(echo "${resultJson}" | jq ".status.code")
    statusCode=${Code//\"/}

    #判断解析结果
    if [ ${statusCode} -eq 1 ]; then
        logInfo="记录更新成功[oldIp:${oldIp} newIp:${1}]"
        formatLogWrite "$logInfo" info updataDnspodRecordIp 0
        return 0
    elif [ ${statusCode} -eq 6 ]; then
        logInfo="域名ID错误"
        formatLogWrite $logInfo error updataDnspodRecordIp 1
        exit 1
    elif [ ${statusCode} -eq 8 ]; then
        logInfo="域名无效"
        formatLogWrite $logInfo error updataDnspodRecordIp 1
        exit 1
    elif [ ${statusCode} -eq 17 ]; then
        logInfo="记录的值不正确"
        formatLogWrite $logInfo error updataDnspodRecordIp 1
        exit 1
    elif [ ${statusCode} -eq 23 ]; then
        logInfo="子域名级数超出限制"
        formatLogWrite $logInfo error updataDnspodRecordIp 1
        exit 1
    elif [ ${statusCode} -eq 104 ]; then
        logInfo="记录已存在无需添加"
        formatLogWrite $logInfo warning updataDnspodRecordIp 0
        exit 1
    fi

    echo "${resultJson}  ${statusCode}"

    return 1
}

#主函数
main (){

  #IP获取模式
  if [ ${updataModule} -eq 0 ]; then
    getLocalIP
  else
    getInetIpM
    #getInetIpI
  fi

  #记录是否存在
  isDnspodRecord
  if [ $? -eq 1 ]; then  
    #创建记录
    createDnspodRecord

    #判断创建记录的返回值
    if [ $? -eq 1 ]; then
      logInfo="创建空记录失败"
      formatLogWrite "$logInfo" error main 1
      exit 1
    fi

  fi

  #获取dnspod的记录Ip与Id
  getDnspodRecordToIP

  # echo "${updataIP} ${oldIp}"

  if [ "${oldIp}" != "${updataIP}" ]; then
    updataDnspodRecordIp ${updataIP} ${recordId}
  else
    logInfo="记录与当前Ip一致无需更新[recordIp:${oldIp} updataIp:${updataIP}]"
    formatLogWrite "$logInfo" warning main 0
    exit 0
  fi

}


###########
main
###########