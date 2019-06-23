#!/bin/bash


set -e


if [ "$BUILD_LINUX" != "yes" ]; then 
   exit 0
fi


USER_WEBRTC_URL="https://github.com/notedit/webrtc-clone.git"
git clone $USER_WEBRTC_URL src
# disable tests file download
sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS
gclient config --unmanaged --name=src $USER_WEBRTC_URL


gclient sync 


LINUX_OUT_DIR="$SRC_DIR/linux_libs"

mkdir $LINUX_OUT_DIR 

mkdir $SRC_DIR/release


cd $SRC_DIR


set +e 

bash build/install-build-deps.sh 

set -e 


gn gen $LINUX_OUT_DIR --args='is_debug=false target_cpu="x64" rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false'


ninja -C $LINUX_OUT_DIR


 if [ "$RELEASE_LINUX" == "yes" ]; then 
    git clone https://github.com/notedit/webrtc-build-release.git
    cp $LINUX_OUT_DIR/obj/libwebrtc.a  ./webrtc-build-release/linux/
    cd ./webrtc-build-release
    git lfs track linux/libwebrtc.a 
    git add linux/libwebrtc.a 
    git add .gitattributes
    git commit -a -m "release linux"
    git remote set-url origin https://${GH_TOKEN}@github.com/notedit/webrtc-build-release.git > /dev/null 2>&1
    git remote -v
    git push https://${GH_TOKEN}@github.com/notedit/webrtc-build-release.git master
 fi


