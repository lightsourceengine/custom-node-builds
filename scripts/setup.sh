#!/bin/bash

set -e

BLD_TARGET_ARCH=$1
BLD_TOOLCHAIN_PREFIX=$2
BLD_NODE_VERSION=$3

###############################################################################
# Download node source code
###############################################################################

curl "https://nodejs.org/dist/v${BLD_NODE_VERSION}/node-v${BLD_NODE_VERSION}.tar.xz" | tar -xJ
cd "node-v${BLD_NODE_VERSION}"

###############################################################################
# Export compiler variables based on arch
###############################################################################

# The -march flag is added to convince node configure to choose the correct arm version. The -mfloat-abi and
# -mfpu flags seem to be chosen automatically by configure and cannot be overridden.

case ${BLD_TARGET_ARCH} in
  armv6l)
    # Settings for Raspberry Pi Zero (should work for Pi 1)
    FLAGS="-march=armv6zk"
  ;;
  armv7l)
    # Settings for Raspberry Pi 2/3/4.
    # configure will choose -mfpu=vfp3 for arm7. neon would be preferred, but the build breaks (v8 and other dependencies)
    # when neon is used.
    FLAGS="-march=armv7-a"
  ;;
  *)
    echo "${BLD_TARGET_ARCH} is not a valid BLD_TARGET_ARCH value. [armv6l,armv7l]"
    exit 1
  ;;
esac

export CC_host="gcc-8 -m32"
export CXX_host="g++-8 -m32"
export CXX="${BLD_TOOLCHAIN_PREFIX}-g++ ${FLAGS}"
export CC="${BLD_TOOLCHAIN_PREFIX}-gcc ${FLAGS}"
