#!/usr/bin/env bash

set -e

if [ "$VERSION" = "4" ];then
    /opt/build4.sh
else
    /opt/build3.sh
fi
