title: 移动端数据安全解决方案之加密传输https
date: 2016-12-12 17:53:04
tags:
---
# 前言  
现在，各个厂家对数据安全越来越重视，而https是保证数据在网络传输中，不被窃取的有效方式之一。而https也是每个App的标配,通过下面你可以了解到，App如何通过自签名证书，实现数据的https加密传输

# 签发证书  
对于有第三方机构签发的https的证书来说，android链接是比较方便的。直接通过https即可具体的链接代码  

# 自签发证书  
通过脚本生成自签发证书  
在Linux系统下，可以自动生成签发证书  
```
#!/bin/bash

dir=`pwd`/tmp/ssl
workspace=`pwd`

if [ -d $dir ]; then
    printf "${dir} already exists, remove it?  yes/no: "
    read del
    if [ $del = "yes" ]; then
        rm -rf $dir
    else
        echo "user cancel"
    fi
fi

for d in ${dir} "${dir}/root" "${dir}/server" "${dir}/client" "${dir}/certs"
do
    if [ ! -d $d ]; then
        mkdir -p $d
    fi
done

echo 'hello world!' >> "${dir}/index.php"
echo 01 > "${dir}/serial"

index_file="${dir}/index.txt"
rm -f $index_file
touch $index_file

echo "generate openssl.cnf: "
openssl_cnf="${dir}/openssl.cnf"
touch $openssl_cnf
echo "[ ca ]
default_ca = yaoguais_ca

[ yaoguais_ca ]
certificate = ./ca.crt
private_key = ./ca.key
database = ./index.txt
serial = ./serial
new_certs_dir = ./certs

default_days = 3650
default_md = sha1

policy = yaoguais_ca_policy
x509_extensions = yaoguais_ca_extensions

[ yaoguais_ca_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = optional
emailAddress = optional
organizationName = optional
organizationalUnitName = optional

[ yaoguais_ca_extensions ]
basicConstraints = CA:false

[ req ]
default_bits = 2048
default_keyfile = ./ca.key
default_md = sha1
prompt = yes
distinguished_name = root_ca_distinguished_name
x509_extensions = root_ca_extensions

[ root_ca_distinguished_name ]
countryName_default = CN

[ root_ca_extensions ]
basicConstraints = CA:true
keyUsage = cRLSign, keyCertSign

[ server_ca_extensions ]
basicConstraints = CA:false
keyUsage = keyEncipherment

[ client_ca_extensions ]
basicConstraints = CA:false
keyUsage = digitalSignature" > $openssl_cnf

# exit 0

cd $dir
echo "generate root ca: "
# in this step, I always input a password of "111111"
openssl genrsa -des3 -out root/ca.key 2048
# in this step, I always input these and a password of "111111"
#Country Name (2 letter code) [XX]:CN
#State or Province Name (full name) []:Si Chuan
#Locality Name (eg, city) [Default City]:Cheng Du
#Organization Name (eg, company) [Default Company Ltd]:Yao Guai Ltd
#Organizational Unit Name (eg, section) []:Yao Guai
#Common Name (eg, your name or your server's hostname) []:yaoguai.com
#Email Address []:newtopstdio@163.com
#A challenge password []:111111
#An optional company name []:Yao Guai Ltd
openssl req -new -newkey rsa:2048 -key root/ca.key -out root/ca.csr
openssl x509 -req -days 3650 -in root/ca.csr -signkey root/ca.key -out root/ca.crt

echo "generate server keys: "
# in this step, I always input a password of "111111"
openssl genrsa -des3 -out server/server.key 2048
# in this step, I always input these and a password of none
#Country Name (2 letter code) [XX]:CN
#State or Province Name (full name) []:Si Chuan
#Locality Name (eg, city) [Default City]:Cheng Du
#Organization Name (eg, company) [Default Company Ltd]:Yao Guai Ltd
#Organizational Unit Name (eg, section) []:Yao Guai
#Common Name (eg, your name or your server's hostname) []:yaoguai.com
#Email Address []:newtopstdio@163.com
#A challenge password []:none
#An optional company name []:none
openssl req -new -newkey rsa:2048 -key server/server.key -out server/server.csr
openssl ca -config openssl.cnf -in server/server.csr -cert root/ca.crt -keyfile root/ca.key -out server/server.crt -days 3650

echo "generate client keys: "
# in this step, I always input a password of "111111"
openssl genrsa -des3 -out client/client.key 2048
# in this step, I always input these and a password of none
#Country Name (2 letter code) [XX]:CN
#State or Province Name (full name) []:Si Chuan
#Locality Name (eg, city) [Default City]:Cheng Du
#Organization Name (eg, company) [Default Company Ltd]:Yao Guai Ltd
#Organizational Unit Name (eg, section) []:Yao Guai
#Common Name (eg, your name or your server's hostname) []:yaoguai.com
#Email Address []:newtopstdio@163.com
#A challenge password []:none
#An optional company name []:none
openssl req -new -newkey rsa:2048 -key client/client.key -out client/client.csr
# to prevent error "openssl TXT_DB error number 2 failed to update database"
echo "unique_subject = no" > "index.txt.attr"
openssl ca -config openssl.cnf -in client/client.csr -cert root/ca.crt -keyfile root/ca.key -out client/client.crt -days 3650

# use these to config nginx
: <<EOF
    ssl on;
    ssl_verify_client on;
    ssl_certificate /tmp/ssl/server/server.crt;
    ssl_certificate_key /tmp/ssl/server/server.key;
    ssl_client_certificate /tmp/ssl/root/ca.crt;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
    ssl_prefer_server_ciphers on;
EOF

echo "helps:"
# view key's file information
echo "openssl rsa -in xxx.key -text -noout"
# view csr's file information
echo "openssl req -noout -text -in xxx.csr"
# pem convert to der
echo "openssl x509 -in server/server.crt -outform DER -out server/server.cer"
# validate key
echo 'curl -k --cert client/client.crt --key client/client.key --pass 111111 https://devel/index.php'
# generate p12 file
echo "openssl pkcs12 -export -in client/client.crt -inkey client/client.key -out client/client.p12 -certfile root/ca.crt"

cd $workspace

```

### 导出证书  
前面生成了服务端使用的密钥对，现在可以通过它生成证书给客户端使用  
```
openssl pkcs12 -export -in client/client.crt -inkey client/client.key -out client/client.p12 -certfile root/ca.crt
```

## 服务端准备  
一般现在的网络结构都是通过nginx作方向代理，所以直接设置在nginx即可。  




### 转换证书  
#### 将 KeyStore 变更为 PKCS#12 格式
```
keytool -importkeystore -srcstoretype JKS -srckeystore server.jks -srcstorepass 111111 -srcalias server -srckeypass 111111 -deststoretype PKCS12 -destkeystore server.p12 -deststorepass 111111 -destalias server -destkeypass 111111 -noprompt
```
#### 使用 OpenSSL 解析 PKCS#12 格式的 KeyStore，并转化为 PEM 格式(包含证书和私钥)  
```
openssl pkcs12 -in server.p12 -out server.pem.p12 -passin pass:111111 -passout pass:111111
```
#### 单独输出私钥和公钥  
```
openssl rsa -in server.pem.p12 -passin pass:111111 -out server.pem.key -passout pass:111111
openssl rsa -in server.pem.p12 -passin pass:111111 -out server.pem.pub -pubout
```
#### 单独输出证书  
```
openssl x509 -in server.pem.p12 -out server.pem.cer
```
#### 通过私钥生成CSR证书签名  
```
openssl req -new -key server.pem.key -out server.certrequest.csr
```
#### 通过私钥和证书签名生成证书文件  
```
openssl x509 -req -in server.certrequest.csr -signkey server.pem.key -out server.certificate.pem
```
# 参考  
http://blog.chinaunix.net/uid-631975-id-3313151.html  
