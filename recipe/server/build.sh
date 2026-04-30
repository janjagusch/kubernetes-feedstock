#!/usr/bin/env bash

# hack/lib/init.sh needs bash >=4.2; macOS system bash is 3.2.
# Re-exec under the build-env bash if we were launched with an older one.
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ] && [ -x "${BUILD_PREFIX}/bin/bash" ]; then
  exec "${BUILD_PREFIX}/bin/bash" "$0" "$@"
fi

set -euf

HOST_GOOS="$(go env GOHOSTOS)"
HOST_GOARCH="$(go env GOHOSTARCH)"

if [[ "$GOOS" != "$HOST_GOOS" || "$GOARCH" != "$HOST_GOARCH" ]]; then
  export KUBE_BUILD_PLATFORMS="${GOOS}/${GOARCH}"
  OUTPUT_DIR="local/bin/${KUBE_BUILD_PLATFORMS}"
else
  OUTPUT_DIR=bin
fi

# This comes from k8s
. hack/lib/init.sh

mkdir -p "$PREFIX/bin"
export GO_TMPDIR=$SRC_DIR/tmp
go env

make all WHAT="${KUBE_SERVER_TARGETS[*]}"

for cmd in ${KUBE_SERVER_BINARIES[*]}; do
  cp "_output/${OUTPUT_DIR}/${cmd}" "$PREFIX/bin"
done

#
# For some reason the binary patching destroys this file
# In that case, we are better off deleting it.
rm -f "$PREFIX"/bin/apiextensions-apiserver

for cmd in ${KUBE_NODE_BINARIES[*]} ${KUBE_CLIENT_BINARIES[*]}; do
  rm -f "$PREFIX/bin/${cmd}"
done
