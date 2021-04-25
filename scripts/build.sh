#!/bin/bash

set -e

source scripts/setup.sh "$@"

make \
  -j$(getconf _NPROCESSORS_ONLN) \
  binary \
  V= \
  DESTCPU="arm" \
  ARCH="${$1}" \
  DISTTYPE="release"
