#!/bin/sh
DOMAIN_HOST=`ifconfig eth0 | grep "inet" | awk '{ print $2}' | sed -n '1p;1q'`
#DOMAIN_HOST=`hostname` #选择域名方案最好
HOST=$DOMAIN_HOST
# 自定义信息
PASSWORD="yourPassword"
COUNTRY=CN
PROVINCE=gd
CITY=gz
ORGANIZATION=dounine
GROUP=dg
NAME=lake
SUBJ="/C=$COUNTRY/ST=$PROVINCE/L=$CITY/O=$ORGANIZATION/OU=$GROUP/CN=$HOST"
# 自定义信息
#============================================================================================
#此形式是自己给自己签发证书,自己就是CA机构,也可以交给第三方机构去签发
# 生成根证书RSA私钥,password作为私钥密码
openssl genrsa -passout pass:$PASSWORD -aes256 -out pem/ca-key.pem 4096
# 2.用根证书RSA私钥生成自签名的根证书
openssl req -new -x509 -days 365 -passin pass:$PASSWORD -key pem/ca-key.pem -sha256 -subj $SUBJ -out pem/ca.pem
#============================================================================================
#给服务器签发证书
# 1.服务端生成自己的私钥
openssl genrsa -out pem/server-key.pem 4096
# 2.服务端生成证书(里面包含公钥与服务端信息)
openssl req -new -sha256 -key pem/server-key.pem -out pem/server.csr -subj "/CN=$DOMAIN_HOST"
# 3.通过什么形式与我进行连接,可设置多个IP地扯用逗号分隔
echo subjectAltName=IP:$DOMAIN_HOST > /tmp/extfile.cnf
# 4.权威机构对证书进行进行盖章生效
openssl x509 -passin pass:$PASSWORD -req -days 365 -sha256 -in pem/server.csr -CA pem/ca.pem -CAkey pem/ca-key.pem -CAcreateserial -out pem/server-cert.pem -extfile /tmp/extfile.cnf
#============================================================================================
#给客户端签发证书
openssl genrsa -out pem/client-key.pem 4096
openssl req -subj '/CN=client' -new -key pem/client-key.pem -out pem/client.csr
echo extendedKeyUsage = clientAuth > /tmp/extfile.cnf
openssl x509 -passin pass:$PASSWORD -req -days 365 -sha256 -in pem/client.csr -CA pem/ca.pem -CAkey pem/ca-key.pem -CAcreateserial -out pem/client-cert.pem -extfile /tmp/extfile.cnf
#============================================================================================
# 清理文件
rm -rf pem/ca-key.pem
rm -rf pem/{server,client}.csr
rm -rf pem/ca.srl
# 最终文件
# ca.pem  ==  CA机构证书
# client-cert.pem  ==  客户端证书
# client-key.pem  ==  客户私钥
# server-cert.pem  == 服务端证书
# server-key.pem  ==  服务端私钥

# 调用生成证书
# chmod +x tls.sh
# bash tls.sh

#
#{
#    "hosts": ["tcp://0.0.0.0:2376","unix:///var/run/docker.sock"],
#    "tlsverify":true,
#    "tlscacert":"/root/tls/pem/ca.pem",
#    "tlscert":"/root/tls/pem/server-cert.pem",
#    "tlskey":"/root/tls/pem/server-key.pem"
#}
#
#让配置生效
#
#systemctl daemon-reload
#systemctl restart docker
#
#测试连接
#docker --tlsverify --tlscacert=pem/ca.pem --tlscert=pem/client-cert.pem --tlskey=pem/client-key.pem -H tcp://172.16.0.3:2376 version

