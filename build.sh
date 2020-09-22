collect() {
    echo `cat README.md | grep sdrzlyz/$1 | head -n1 | awk '{print $2}'`
}

BUILD_INFO=`collect $1`

# echo $BUILD_INFO

IFS=":" read -ra TARGET <<< "$BUILD_INFO"

DNAME=${TARGET[0]}
DTAG=${TARGET[1]:-latest}

echo "name:$DNAME, tag:$DTAG"

cd $1

sed -i "s#\$BUILD_VER#$DTAG#g" Dockerfile
docker build -t $DNAME:$DTAG .
docker push $DNAME:$DTAG

# latest
if [ "$DTAG" != "latest" ];then
    docker tag $DNAME:$DTAG $DNAME:latest
    docker push $DNAME:latest
fi

cd ..
