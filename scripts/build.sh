#!/bin/bash

set -e

source "$(cd "$(dirname "$0")" && pwd -P)/setup.sh" "$@"

make \
  -j$(getconf _NPROCESSORS_ONLN) \
  binary \
  V= \
  DESTCPU="arm" \
  ARCH="${$1}" \
  DISTTYPE="release"
