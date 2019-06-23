#!/bin/bash


# exit if there is an error 
set -e 



if [ "$BUILD_ANDROID" != "yes" ]; then 
   exit 0
fi


USER_WEBRTC_URL="https://github.com/notedit/webrtc-clone.git"
git clone $USER_WEBRTC_URL src
# disable tests file download
sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS
gclient config --unmanaged --name=src $USER_WEBRTC_URL

echo "target_os = ['unix', 'android']" >> .gclient

gclient sync 


ANDROID_OUT_DIR="$SRC_DIR/android_libs"
ANDROID_PYTHON_ARGS="--build-dir $ANDROID_OUT_DIR --arch $TARGET_ARCH --extra-gn-args rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_enable_protobuf=false rtc_libvpx_build_vp9=false rtc_include_ilbc=false disable_libfuzzer=true libyuv_include_tests=false libyuv_disable_jpeg=true"

mkdir $ANDROID_OUT_DIR 

mkdir $SRC_DIR/release

cp $ROOT_DIR/build_aar.py $SRC_DIR/tools_webrtc/android/

cd $SRC_DIR

# remove git-svn install, this will have an error 
sed -i '/git-svn/d' build/install-build-deps.sh 



set +e 

bash build/install-build-deps-android.sh 

source build/android/envsetup.sh 


set -e 

# build ios
python tools_webrtc/android/build_aar.py $ANDROID_PYTHON_ARGS



 if [ "$RELEASE_ANDROID" == "yes" ]; then 
    git clone https://github.com/notedit/webrtc-build-release.git
    mkdir -p ./webrtc-build-release/android/$TARGET_ARCH/
    cp $SRC_DIR/libwebrtc.aar  ./webrtc-build-release/android/$TARGET_ARCH/
    cd ./webrtc-build-release
    git lfs track android/$TARGET_ARCH/libwebrtc.aar
    git add android/$TARGET_ARCH/libwebrtc.aar
    git add .gitattributes
    git commit -a -m "release android"
    git remote set-url origin https://${GH_TOKEN}@github.com/notedit/webrtc-build-release.git > /dev/null 2>&1
    git remote -v
    git push https://${GH_TOKEN}@github.com/notedit/webrtc-build-release.git master > /dev/null 2>&1
 fi
