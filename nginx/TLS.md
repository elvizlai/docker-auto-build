### 创建目录
```
mkdir -p /opt/tls/{ca,server,client}
cd /opt/tls
```

### 1. 生成 Root CA
```
# 生成 CA 私钥（ECC prime256v1）
openssl ecparam -name prime256v1 -genkey -noout -out ca/ca.key

# 生成 CA 证书（自签名，100 年）
openssl req -x509 -new -sha256 \
  -key ca/ca.key \
  -days 36500 \
  -out ca/ca.crt \
  -subj "/C=CN/O=MORN/OU=IT/CN=RootCA"
```

### 2. 生成服务端证书（Server Cert）
```
# 生成 Server 私钥
openssl ecparam -name prime256v1 -genkey -noout -out server/server.key

# 生成 CSR
openssl req -new -sha256 \
  -key server/server.key \
  -out server/server.csr \
  -subj "/C=CN/O=MORN/OU=IT/CN=MornServer"

# 创建 server.ext（包含 SAN 扩展）
cat > server/server.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = hijack.local
DNS.2 = *.hijack.local
EOF

# 签发 Server Cert
openssl x509 -req \
  -in server/server.csr \
  -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial \
  -out server/server.crt \
  -days 36500 -sha256 \
  -extfile server/server.ext
```

### 3. 生成客户端证书（Client Cert）
```
# 生成 Client 私钥
openssl ecparam -name prime256v1 -genkey -noout -out client/client.key

# 生成 CSR（客户端无需 SAN）
openssl req -new -sha256 \
  -key client/client.key \
  -out client/client.csr \
  -subj "/C=CN/O=MORN/OU=IT/CN=MornClientRPC"

# 创建 client.ext
cat > client/client.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature
extendedKeyUsage = clientAuth
EOF

# 签发 Client Cert
openssl x509 -req \
  -in client/client.csr \
  -CA ca/ca.crt -CAkey ca/ca.key \
  -CAcreateserial \
  -out client/client.crt \
  -days 36500 -sha256 \
  -extfile client/client.ext

# （可选）生成客户端 P12 用于浏览器 / curl
openssl pkcs12 -export \
  -inkey client/client.key \
  -in client/client.crt \
  -certfile ca/ca.crt \
  -out client/client.p12
```

#### Nginx 配置及 Curl 测试
```
    # nginx.conf

    # 指定受信任的客户端 CA（用于验证客户端证书）
    ssl_client_certificate /etc/nginx/ca.crt;

    # 验证模式
    ssl_verify_client on;          # 强制验证（无证书则拒绝）
    # ssl_verify_client optional; # 可选（有证书就验证，无证书也放行）

    ssl_verify_depth 2;

    # 为后端传递客户端证书信息（可选）
    proxy_set_header X-Client-Cert $ssl_client_cert;
    proxy_set_header X-Client-Verify $ssl_client_verify;


curl -k -v https://xxx.hijack.local --cert client.p12 --cert-type p12
```