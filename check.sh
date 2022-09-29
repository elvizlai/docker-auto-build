#!/usr/bin/env bash

# check if exist
check_pg() {
    local container_id="$(docker run -itd --rm -e POSTGRES_HOST_AUTH_METHOD=trust $1)"
    sleep 10
    if [ -n "$(docker ps -q -f id=$container_id)" ]; then
        echo "1"
    fi
}
