#!/usr/bin/env bash
set -eufx

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

mkdir -p "$PREFIX"/bin
export GO_TMPDIR=$SRC_DIR/tmp
go env

make all WHAT="${KUBE_NODE_TARGETS[*]}"

for cmd in ${KUBE_NODE_BINARIES[*]}; do
  cp "_output/${OUTPUT_DIR}/${cmd}" "$PREFIX/bin"
done
