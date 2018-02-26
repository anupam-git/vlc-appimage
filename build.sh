#/bin/bash

if [ -z "$IS_CI" ]
then
  echo "deb http://in.archive.ubuntu.com/ubuntu/ trusty main" | tee /etc/apt/sources.list.d/trusty.list
  apt-get update
  apt-get --yes install python-software-properties software-properties-common
  add-apt-repository ppa:jonathonf/ffmpeg-3 --yes
  add-apt-repository universe --yes
  apt-get update
  apt-get --yes dist-upgrade

  apt-get --yes install \
    curl
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    patchelf \
    libtasn1-3-dev \
    libtasn1-3-bin \
    libbsd-dev \
    git \
    bison \
    libqt5svg5-dev \
    automake \
    autopoint \
    gettext \
    cmake \
    wayland-protocols \
    protobuf-compiler \
    libmpg123-dev \
    libgstreamer-plugins-base1.0-dev \
    libsystemd-dev \
    libarchive-dev \
    libopencv-dev

  apt-get build-dep vlc --yes
fi

(
  git clone https://github.com/videolabs/libdsm.git
  cd libdsm
  ./bootstrap
  ./configure
  make -j$(nproc)
  make -j$(nproc) install
)

(
  git clone https://github.com/sahlberg/libnfs.git
  cd libnfs/
  cmake .
  make -j$(nproc)
  make -j$(nproc) install
)

(
  wget http://download.videolan.org/pub/vlc/3.0.0/vlc-3.0.0.tar.xz
  tar xJf vlc-3.0.0.tar.xz
  cd vlc-3.0.0
  ./configure --enable-chromecast=no --prefix=/usr
  make -j$(nproc)
  make -j$(nproc) DESTDIR=$(pwd)/build/ install
  cd build
  cp ../../org.videolan.vlc.desktop ./
  cp ./usr/share/icons/hicolor/256x256/apps/vlc.png ./
  mkdir -p ./usr/plugins/iconengines/
  cp /usr/lib/x86_64-linux-gnu/qt5/plugins/iconengines/libqsvgicon.so ./usr/plugins/iconengines/
  mkdir -p ./usr/plugins/platforms/
  cp /usr/lib/x86_64-linux-gnu/qt5/plugins/platforms/libqxcb.so ./usr/plugins/platforms/
  rm usr/lib/vlc/plugins/plugins.dat
)

chmod a+x run-patchelf.sh
run-patchelf.sh

wget "https://github.com/azubieta/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
# wget "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x ./linuxdeployqt-continuous-x86_64.AppImage
LINUX_DEPLOY_QT_EXCLUDE_COPYRIGHTS=true ./linuxdeployqt-continuous-x86_64.AppImage vlc-3.0.0/build/org.videolan.vlc.desktop -bundle-non-qt-libs
# LINUX_DEPLOY_QT_EXCLUDE_COPYRIGHTS=true ../../linuxdeployqt-continuous-x86_64.AppImage org.videolan.vlc.desktop -appimage

mkdir release

wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod a+x ./appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage vlc-3.0.0/build/
cp ./VLC_media_player*.AppImage release/

md5sum ./VLC_media_player*.AppImage > release/md5.txt

wget https://github.com/probonopd/uploadtool/raw/master/upload.sh -O u.sh
curl --upload-file ./VLC_media_player*.AppImage https://transfer.sh/ > release/URL
./u.sh release/*
