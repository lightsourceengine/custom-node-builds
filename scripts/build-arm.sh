#!/bin/sh

set -e

node-build () {
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
    CONFIG_FLAGS="--without-npm --cross-compiling $2"
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

case ${BLD_TARGET_ARCH} in
  armv6l)
    # Optimizations for Raspberry Pi Zero
    FLAGS="-mcpu=arm1176jzf-s -mfloat-abi=hard -mfpu=vfp"
  ;;
  armv7l)
    # TODO: is neon supported on all Raspberry Pi boards?
    FLAGS="-mtune=cortex-a7 -mfpu=neon-vfpv4"
  ;;
  *)
    echo "${BLD_TARGET_ARCH} is not a valid BLD_TARGET_ARCH value. [armv6l,armv7l]"
    exit 1
  ;;
esac

export CC_host="ccache gcc-6 -m32"
export CXX_host="ccache g++-6 -m32"
export CXX="ccache ${CROSSTOOLS_HOME}/x64-gcc-6.3.1/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-g++ ${FLAGS}"
export CC="ccache ${CROSSTOOLS_HOME}/x64-gcc-6.3.1/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-gcc ${FLAGS}"

###############################################################################
# Run custom node builds
###############################################################################

# ccache is being used, so the subsequent build completes very quickly (workaround parallel build limit in CI service)

node-build "xnpm,xintl"
node-build "xnpm,xintl,xhttp" "--without-ssl"

# note: at this point, tar balls from all builds will be in node source root, ready to be uploaded to s3