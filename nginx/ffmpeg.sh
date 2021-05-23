#!/usr/bin/env bash

# yum install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
# yum install -y ffmpeg

echo "add ffmpeg static file"

curl -sSL https://x.morn.io/dl/ffmpeg/ffmpeg > /usr/bin/ffmpeg
curl -sSL https://x.morn.io/dl/ffmpeg/ffprobe > /usr/bin/ffprobe
chmod +x /usr/bin/ffmpeg /usr/bin/ffprobe

# 4.x
# cd /tmp
# curl -sSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o ffmpeg.tar.xz
# tar -xf ffmpeg.tar.xz -C . --strip-components 1
# \cp ffmpeg /usr/bin/ffmpeg
# \cp ffprobe /usr/bin/ffprobe
# rm -rf /tmp/*

# location /live_stat {
#     rtmp_stat all;
#     rtmp_stat_stylesheet live_stat.xsl;
# }

# location /live_stat.xsl {
#     root html/rtmp;
# }
