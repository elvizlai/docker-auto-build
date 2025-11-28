```
docker build -f Dockerfile-stable -t sdrzlyz/nginx:stable .
```

### 日志轮转
```
cat > /etc/logrotate.d/docker-nginx <<EOF
/var/log/nginx/*.log {
    create 0644 root root
    daily
    dateext
    rotate 7
    missingok
    notifempty
    nocompress
    sharedscripts
    postrotate
        docker kill --signal="USR1" nginx
    endscript
}
EOF

# 测试配置是否正确
sudo logrotate -d /etc/logrotate.d/docker-nginx

# 手动执行一次轮转（可选）
sudo logrotate -f /etc/logrotate.d/docker-nginx
```
