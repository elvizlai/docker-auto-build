# TODO remove if exist dir envoy-src

# need if GFW:
# export https_proxy=http://192.168.3.101:7890 http_proxy=http://192.168.3.101:7890 all_proxy=socks5://192.168.3.101:7890

VERSION="1.27.0"

git clone -b v${VERSION} --depth 1 https://github.com/envoyproxy/envoy envoy-src

cd envoy-src

export ENVOY_DOCKER_BUILD_DIR=~/tmp/envoy-docker-build/

# genedated file: ~/tmp/envoy-docker-build/
./ci/run_envoy_docker.sh 'BAZEL_BUILD_EXTRA_OPTIONS="--define exported_symbols=enabled" ./ci/do_ci.sh bazel.sizeopt.server_only'
# ./ci/run_envoy_docker.sh 'BAZEL_BUILD_EXTRA_OPTIONS="--define exported_symbols=enabled" ./ci/do_ci.sh bazel.release.server_only'
