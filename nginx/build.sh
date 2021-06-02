#!/usr/bin/env bash

set -e

FFMPEG=0

if [ "$VERSION" = "ffmpeg" ];then
    VERSION="1.20.1"
    FFMPEG=1
fi

/opt/dep.sh
/opt/nginx.sh $VERSION

if [ "$FFMPEG" = "1" ];then
    /opt/ffmpeg.sh
fi
