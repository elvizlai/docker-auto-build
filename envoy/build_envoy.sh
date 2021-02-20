# TODO remove if exist dir envoy-src
git clone -b v1.17.0 --depth 1 https://github.com/envoyproxy/envoy envoy-src

cd envoy-src

./ci/run_envoy_docker.sh 'BAZEL_BUILD_EXTRA_OPTIONS="--define exported_symbols=enabled" ./ci/do_ci.sh bazel.release.server_only'
# ./ci/run_envoy_docker.sh 'BAZEL_BUILD_EXTRA_OPTIONS="--define exported_symbols=enabled" ./ci/do_ci.sh bazel.sizeopt.server_only'
