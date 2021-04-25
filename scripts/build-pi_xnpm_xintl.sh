#!/bin/bash

set -e

source "$(cd "$(dirname "$0")" && pwd -P)/setup.sh" "$@"

make \
  -j$(getconf _NPROCESSORS_ONLN) \
  binary \
  V= \
  DESTCPU="arm" \
  ARCH="${$1}" \
  DISTTYPE="custom" \
  CUSTOMTAG="pi_xnpm_xintl" \
  BUILD_INTL_FLAGS="--with-intl=none" \
  BUILD_DOWNLOAD_FLAGS="--download=none" \
  CONFIG_FLAGS="--without-npm"
