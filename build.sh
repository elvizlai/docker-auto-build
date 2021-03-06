#!/usr/bin/env bash

set -e

collect() {
    echo `cat README.md | grep sdrzlyz/$1 | head -n1 | awk '{print $2}'`
}

BUILD_INFO=`collect $1`

# echo $BUILD_INFO

IFS=":" read -ra TARGET <<< "$BUILD_INFO"

DNAME=${TARGET[0]:-$1}
DTAG=${TARGET[1]:-latest}

if [ "$2" != "" ];then
    DTAG=$2
fi

echo -e "\033[33mimg-->$DNAME:$DTAG\033[0m"

cd $1

imgList=()

sed -i "s#\$BUILD_VER#$DTAG#g" Dockerfile
docker build -t "$DNAME:$DTAG" --build-arg VERSION=$DTAG .
imgList+=("$DNAME:$DTAG")

# latest
if [ "$DTAG" != "latest" -a "$2" = "" ];then
    docker tag "$DNAME:$DTAG" "$DNAME:latest"
    imgList+=("$DNAME:latest")
fi

if [ "$DSKIPPUSH" != "true" ];then
    for img in "${imgList[@]}"
    do
        echo "img to push $img"
        docker push "$img"
    done
fi

cd ..
