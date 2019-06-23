#!/bin/bash


set -e

USER_WEBRTC_URL="https://github.com/notedit/webrtc-clone.git"
git clone $USER_WEBRTC_URL src
# disable tests file download
sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS
gclient config --unmanaged --name=src $USER_WEBRTC_URL


gclient sync 



set +e 

bash build/install-build-deps-android.sh 

set -e 

LINUX_OUT_DIR="$SRC_DIR/linux_libs"

mkdir $LINUX_OUT_DIR 

mkdir $SRC_DIR/release


cd $SRC_DIR


gn gen $LINUX_OUT_DIR --args='is_debug=false target_cpu="x64" rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false'


ninja -C $LINUX_OUT_DIR




ls -al  $LINUX_OUT_DIR/
ls -al 

