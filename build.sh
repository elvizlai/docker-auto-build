collect() {
    echo `cat README.md | grep sdrzlyz/$1 | head -n1 | awk '{print $2}'`
}

VER=`collect $1`

# echo $VER

BUILD_VER=${VER#*:}

# echo $BUILD_VER

cat $1/Dockerfile | sed "s#\$BUILD_VER#$BUILD_VER#g" | docker build -t $VER - 
docker push $VER
