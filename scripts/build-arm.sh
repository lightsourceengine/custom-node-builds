#!/bin/sh

set -e

node_build() {
  make \
    -j$(getconf _NPROCESSORS_ONLN) \
    binary \
    V= \
    DESTCPU="arm" \
    ARCH="${BLD_TARGET_ARCH}" \
    DISTTYPE="custom" \
    CUSTOMTAG="$1" \
    BUILD_INTL_FLAGS="--with-intl=none" \
    BUILD_DOWNLOAD_FLAGS="--download=none" \
    CONFIG_FLAGS="--without-npm $2"
}

###############################################################################
# Setup output directory
###############################################################################

OUTPUT_HOME="$(cd "$(dirname "$0")" && pwd -P)/../out"
mkdir -p "${OUTPUT_HOME}"
cd "${OUTPUT_HOME}"

###############################################################################
# Download node source code
###############################################################################

curl "https://nodejs.org/dist/v${BLD_NODE_VERSION}/node-v${BLD_NODE_VERSION}.tar.xz" | tar -xJ
cd "node-v${BLD_NODE_VERSION}"

###############################################################################
# Configure compiler flags for cross compiling
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

export CC_host="ccache gcc-8 -m32"
export CXX_host="ccache g++-8 -m32"
export CXX="ccache ${BLD_TOOLCHAIN_PREFIX}-g++ ${FLAGS}"
export CC="ccache ${BLD_TOOLCHAIN_PREFIX}-gcc ${FLAGS}"

###############################################################################
# Run custom node builds
###############################################################################

# ccache is being used, so the subsequent build completes very quickly (workaround parallel build limit in CI service)

node_build "pi_xnpm_xintl"
node_build "pi_xnpm_xintl_xhttp" "--without-ssl"

# note: at this point, tar balls from all builds will be in node source root, ready to be uploaded to s3
