#!/bin/bash




USER_WEBRTC_URL="https://github.com/notedit/webrtc-clone.git"
git clone $USER_WEBRTC_URL src
# disable tests file download
sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS
gclient config --unmanaged --name=src $USER_WEBRTC_URL
gclient sync 





MAC_OUT_DIR="$SRC_DIR/mac_libs"
MAC_PYTHON_ARGS="--output-dir $MAC_OUT_DIR --arch x64 --extra-gn-args rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_enable_protobuf=false"


mkdir $MAC_OUT_DIR

mkdir $SRC_DIR/release


cp $ROOT_DIR/*.py $SRC_DIR/tools_webrtc/ios/


cd $SRC_DIR

# build mac 
python tools_webrtc/ios/build_mac_libs.py $MAC_PYTHON_ARGS

tar -zcvf $SRC_DIR/release/macos.tar.gz   ./mac_libs/WebRTC.framework














