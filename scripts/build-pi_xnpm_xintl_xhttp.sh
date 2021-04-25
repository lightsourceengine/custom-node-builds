#!/bin/bash

set -e

source scripts/setup.sh "$@"

make \
  -j$(getconf _NPROCESSORS_ONLN) \
  binary \
  V= \
  DESTCPU="arm" \
  ARCH="${$1}" \
  DISTTYPE="custom" \
  CUSTOMTAG="pi_xnpm_xintl_xhttp" \
  BUILD_INTL_FLAGS="--with-intl=none" \
  BUILD_DOWNLOAD_FLAGS="--download=none" \
  CONFIG_FLAGS="--without-npm --without-ssl"
