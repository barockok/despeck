#!/bin/bash

vips_site=https://github.com/jcupitt/libvips/releases/download
version=$LIBVIPS_VERSION

set -e

# do we already have the correct vips built? early exit if yes
# we could check the configure params as well I guess
if [ -d "$HOME/vips/bin" ]; then
  installed_version=$($HOME/vips/bin/vips --version)
  echo "Need vips-$version"
  echo "Found $installed_version"
  if [[ "$installed_version" =~ ^vips-$version ]]; then
    echo "Using cached directory"
    exit 0
  fi
fi

rm -rf $HOME/vips
wget $vips_site/v$version/vips-$version.tar.gz
tar xf vips-$version.tar.gz
cd vips-$version
CXXFLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 ./configure --prefix=$HOME/vips $*
make && make install
