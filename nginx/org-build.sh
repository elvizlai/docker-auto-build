#!/usr/bin/env bash

set -e

FFMPEG=0

if [ "$VERSION" = "ffmpeg" ];then
    VERSION="1.20.2"
    FFMPEG=1
fi

/opt/org-dep.sh
/opt/org-nginx.sh $VERSION

if [ "$FFMPEG" = "1" ];then
    /opt/org-ffmpeg.sh
fi
