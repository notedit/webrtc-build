#!/bin/bash


USER_WEBRTC_URL="https://github.com/notedit/webrtc-clone.git"
OUT_DIR="$SRC_DIR/out_ios_libs"
PYTHON_ARGS="--output-dir $OUT_DIR --extra-gn-args rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_enable_protobuf=false"

mkdir $OUT_DIR

git clone $USER_WEBRTC_URL src

# disable tests file download
sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS

gclient config --unmanaged --name=src $USER_WEBRTC_URL

gclient sync 

cd $SRC_DIR

python tools_webrtc/ios/build_ios_libs.py $PYTHON_ARGS

tar -zcvf $SRC_DIR/release.tar.gz $SRC_DIR/out_ios_libs/












