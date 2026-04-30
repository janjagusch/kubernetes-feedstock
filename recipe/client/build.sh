#!/usr/bin/env bash
set -euf

HOST_GOOS="$(go env GOHOSTOS)"
HOST_GOARCH="$(go env GOHOSTARCH)"

if [[ "$GOOS" != "$HOST_GOOS" || "$GOARCH" != "$HOST_GOARCH" ]]; then
  # Cross-compile: Makefile has its own setup for target/platform
  export KUBE_BUILD_PLATFORMS="${GOOS}/${GOARCH}"
  # Only binaries with host arch go to bin/ (replicates go install behavior)
  OUTPUT_DIR="local/bin/${KUBE_BUILD_PLATFORMS}"
else
  OUTPUT_DIR=bin
fi

# This comes from k8s
. hack/lib/init.sh

mkdir -p "$PREFIX"/bin
export GO_TMPDIR=$SRC_DIR/tmp
go env

make all WHAT="${KUBE_CLIENT_TARGETS[*]}"

for cmd in ${KUBE_CLIENT_BINARIES[*]}; do
  cp "_output/${OUTPUT_DIR}/${cmd}" "$PREFIX/bin"
done
