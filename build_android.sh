#!/bin/bash

set -e


USER_WEBRTC_URL="https://github.com/notedit/webrtc-clone.git"
git clone $USER_WEBRTC_URL src
# disable tests file download
sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS
gclient config --unmanaged --name=src $USER_WEBRTC_URL

echo "target_os = ['unix', 'android']" >> .gclient

gclient sync 


ANDROID_OUT_DIR="$SRC_DIR/android_libs"
ANDROID_PYTHON_ARGS="--build-dir $ANDROID_OUT_DIR --arch armeabi-v7a --extra-gn-args rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_enable_protobuf=false rtc_libvpx_build_vp9=false rtc_include_ilbc=false disable_libfuzzer=true libyuv_include_tests=false libyuv_disable_jpeg=true"

mkdir $ANDROID_OUT_DIR 

mkdir $SRC_DIR/release

cp $ROOT_DIR/build_aar.py $SRC_DIR/tools_webrtc/android/

cd $SRC_DIR

bash build/install-build-deps-android.sh 

source build/android/envsetup.sh 


# build ios
python tools_webrtc/android/build_aar.py $ANDROID_PYTHON_ARGS



#tar -zcvf $SRC_DIR/release/android.tar.gz   ./android_libs/