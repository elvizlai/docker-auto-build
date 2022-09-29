#!/usr/bin/env bash

set -e

source check.sh

collect() {
    echo $(cat README.md | grep sdrzlyz/$1 | head -n1 | awk '{print $2}')
}

BUILD_INFO=$(collect $1)

# echo $BUILD_INFO

IFS=":" read -ra TARGET <<< "$BUILD_INFO"

DNAME=${TARGET[0]:-$1}
DTAG=${TARGET[1]:-latest}

if [ "$2" != "" ]; then
    DTAG=$2
fi

echo -e "\033[33mimg-->$DNAME:$DTAG\033[0m"

cd $1

imgList=()

dockerFile="Dockerfile"

# check if file exist
if [ -f "Dockerfile-$DTAG" ]; then
    dockerFile="Dockerfile-$DTAG"
fi

echo "using dockerFile: $dockerFile"

docker build -f $dockerFile -t "$DNAME:$DTAG" --build-arg VERSION=$DTAG .
imgList+=("$DNAME:$DTAG")

# latest
if [ "$DTAG" != "latest" -a "$2" = "" ]; then
    docker tag "$DNAME:$DTAG" "$DNAME:latest"
    imgList+=("$DNAME:latest")
fi

if [ "$DSKIPPUSH" != "true" -a "$DSKIPPUSH" != "1" ]; then
    for img in "${imgList[@]}"
    do
        if [ "$(type -t check_$1)" == function ]; then
            echo -e "\033[35mtry check_$1\033[0m"
            if [ "$(check_$1 $img)" != "1" ]; then
                echo -e "\033[91mcheck $img faild, skip push\033[0m"
                continue
            fi
        fi
        echo -e "\033[31mimg to push $img\033[0m"
        docker push "$img"
    done
fi

cd ..
