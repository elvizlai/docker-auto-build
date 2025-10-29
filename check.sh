#!/usr/bin/env bash

# check if running

check_pg() {
    local container_id="$(docker run -itd -e POSTGRES_HOST_AUTH_METHOD=trust $1)"
    sleep 10
    if [ -n "$(docker ps -q -f id=$container_id)" ]; then
        echo "1"
    else
        echo "failed to start container: $(docker logs $container_id)"
    fi
}

check_nginx() {
    local container_id="$(docker run -itd $1)"
    sleep 10
    if [ -n "$(docker ps -q -f id=$container_id)" ]; then
        echo "1"
    else
        echo "failed to start container: $(docker logs $container_id)"
    fi
}
