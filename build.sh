collect() {
    echo `cat README.md | grep sdrzlyz/$1 | head -n1 | awk '{print $2}'`
}

VER=`collect $1`

# echo $VER

BUILD_VER=${VER#*:}

# echo $BUILD_VER

cd $1

sed -i "s#\$BUILD_VER#$BUILD_VER#g" Dockerfile
docker build -t $VER - 
docker push $VER

cd ..
