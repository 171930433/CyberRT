#!/usr/bin/env bash

set -e

CURRENT_PATH=$(cd $(dirname $0) && pwd)
INSTALL_PREFIX="$CURRENT_PATH/../install/"
ARCH=$(uname -m)

function download() {
  URL=$1
  LIB_NAME=$2
  DOWNLOAD_PATH="$CURRENT_PATH/../third_party/$LIB_NAME/"
  if [ -e $DOWNLOAD_PATH ]
  then
    echo ""
  else
    echo "############### Install $LIB_NAME $URL ################"
    git clone $URL "$DOWNLOAD_PATH"
  fi
}

function init() {
  echo "############### Init. ################"
  if [ -e $INSTALL_PREFIX ]
  then
    echo ""
  else
    mkdir -p $INSTALL_PREFIX
  fi
  chmod a+w $INSTALL_PREFIX
}

function build_setup() {
  echo "############### Build Setup. ################"
  local NAME="setup"
  download "https://github.com/minhanghuang/setup.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  mkdir -p build && cd build
  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  make install -j$(nproc)
  popd
}

function build_nlohmann_json() {
  echo "############### Build Nlohmann Json. ################"
  local NAME="nlohmann_json"
  download "https://github.com/nlohmann/json.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  mkdir -p build && cd build
  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  make install -j$(nproc)
  popd
}

function build_tinyxml2() {
  echo "############### Build Tinyxml2. ################"
  local NAME="tinyxml2"
  download "https://github.com/leethomason/tinyxml2.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  git checkout 8.0.0
  mkdir -p build && cd build
  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  make install -j$(nproc)
  popd
}

function build_fastdds() {
  echo "############### Build Fast-DDS. ################"
  download "https://github.com/eProsima/Fast-RTPS.git" "Fast-RTPS"
  pushd "$CURRENT_PATH/../third_party/Fast-RTPS/"
  git checkout v1.5.0
  git submodule update --init
  patch -p1 < "$CURRENT_PATH/../scripts/FastRTPS_1.5.0.patch"
  mkdir -p build && cd build
  cmake -DEPROSIMA_BUILD=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX ..
  make -j$(nproc)
  make install
  popd

  # local INSTALL_PATH="$CURRENT_PATH/../third_party/"
  # if [[ "${ARCH}" == "x86_64" ]]; then
  #   PKG_NAME="fast-rtps-1.5.0-1.prebuilt.x86_64.tar.gz"
  # else # aarch64
  #   PKG_NAME="fast-rtps-1.5.0-1.prebuilt.aarch64.tar.gz"
  # fi
  # DOWNLOAD_LINK="https://apollo-system.cdn.bcebos.com/archive/6.0/${PKG_NAME}"
  # if [ -e $INSTALL_PATH/$PKG_NAME ]
  # then
  #   echo ""
  # else
  #   wget -t 10 $DOWNLOAD_LINK -P $INSTALL_PATH
  # fi
  # pushd $INSTALL_PATH
  # tar -zxf ${PKG_NAME}
  # cp -r fast-rtps-1.5.0-1/* ../install
  # rm -rf fast-rtps-1.5.0-1
  # popd
}

function build_gfamily() {
  echo "############### Build Google Libs. ################"
  download "https://github.com/gflags/gflags.git" "gflags"
  download "https://github.com/google/glog.git" "glog"
  download "https://github.com/google/googletest.git" "googletest"
  download "https://github.com/protocolbuffers/protobuf.git" "protobuf"

  # gflags
  pushd "$CURRENT_PATH/../third_party/gflags/"
  git checkout v2.2.0
  mkdir -p build && cd build
  CXXFLAGS="-fPIC" cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  make install -j$(nproc)
  popd

  # glog
  pushd "$CURRENT_PATH/../third_party/glog/"
  git checkout v0.4.0
  mkdir -p build && cd build
  if [ "$ARCH" == "x86_64" ]; then
    CXXFLAGS="-fPIC" cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  elif [ "$ARCH" == "aarch64" ]; then
    CXXFLAGS="-fPIC" cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  else
      echo "not support $ARCH"
  fi
  make install -j$(nproc)
  popd
 
  # googletest
  pushd "$CURRENT_PATH/../third_party/googletest/"
  git checkout release-1.10.0
  mkdir -p build && cd build
  CXXFLAGS="-fPIC" cmake -DCMAKE_CXX_FLAGS="-w" -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  make install -j$(nproc)
  popd

  # protobuf
  pushd "$CURRENT_PATH/../third_party/protobuf/"
  git checkout v3.14.0
  cd cmake && mkdir -p build && cd build
  cmake -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX ..
  make install -j$(nproc)
  popd
}

function build_eigen3()
{
  echo "############### Build eigen Libs. ################"
  download "https://gitlab.com/libeigen/eigen.git" "eigen"

  pushd "$CURRENT_PATH/../third_party/eigen/"
  git checkout 3.4
  mkdir -p build && cd build
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX ..
  make install -j$(nproc)
  popd
}

function build_boost()
{
  echo "############### Build boost Libs. download may slowly ################"
  local INSTALL_PATH="$CURRENT_PATH/../third_party/"

  PKG_NAME="boost_1_84_0.tar.gz"
  DOWNLOAD_LINK="https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz"
  wget -t 10 $DOWNLOAD_LINK -P $INSTALL_PATH

  
  pushd $INSTALL_PATH
  tar -zxf ${PKG_NAME}
  cd boost_1_84_0
  ./bootstrap.sh --prefix=$INSTALL_PREFIX
  ./b2 install
  popd

}

function build_ceres() {
  echo "############### Build ceres_solver. ################"
  # install atlas
  sudo apt-get install libatlas-base-dev libsuitesparse-dev -y
  local NAME="ceres-solver"
  download "https://github.com/ceres-solver/ceres-solver.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  git checkout 2.0.0
  mkdir -p build && cd build
  cmake -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  make install -j$(nproc)
  popd
}

function build_sophus() {
  echo "############### Build Sophus. ################"
  local NAME="Sophus"
  download "https://github.com/strasdat/Sophus.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  mkdir -p build && cd build
  cmake -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON ..
  make install -j$(nproc)
  popd
}

function build_flann() {
  echo "############### Build pcl-flann. ################"
  # install liblz4
  sudo apt-get install liblz4-dev -y

  local NAME="flann"
  download "https://github.com/flann-lib/flann.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  mkdir -p build && cd build
  cmake -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON \
        -DBUILD_MATLAB_BINDINGS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_DOC=OFF ..
  make install -j$(nproc)
  popd
}

function build_pcl() {
  # build_flann
  echo "############### Build pcl. ################"
  # install liblz4
  sudo sudo apt-get install libpng-dev libpcap-dev libusb-1.0-0-dev freeglut3-dev libopenni-dev  -y

  local NAME="pcl"
  download "https://github.com/PointCloudLibrary/pcl.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  mkdir -p build && cd build
  cmake -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON  ..
  make install -j$(nproc)
  popd
}


function build_opencv() {
  echo "############### Build opencv. ################"
  local NAME="opencv"
  download "https://github.com/opencv/opencv.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  git checkout 4.x
  mkdir -p build && cd build
  cmake -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON  ..
  make install -j$(nproc)
  popd
}

function build_pangolin() {
  echo "############### Build pangolin. ################"
  sudo apt install libglew-dev -y
  local NAME="pangolin"
  download "https://gitee.com/wystephen/Pangolin.git" "$NAME"
  pushd "$CURRENT_PATH/../third_party/$NAME/"
  # git checkout 4.x
  mkdir -p build && cd build
  cmake -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON  ..
  make install -j$(nproc)
  popd
}



function main() {
  echo "############### Install Third Party. ################"
  init
  # build_setup
  # build_nlohmann_json
  # build_tinyxml2
  # build_gfamily
  # build_fastdds
  # build_eigen3
  # build_boost
  # build_ceres
  # build_sophus
  # build_pcl
  # build_opencv
  # build_pangolin
  return
}

main "$@"
