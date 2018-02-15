#/bin/bash

echo $IS_CI

if [ $IS_CI != "true" ]
then
  echo "deb http://in.archive.ubuntu.com/ubuntu/ trusty main" | sudo tee /etc/apt/sources.list.d/trusty.list
  sudo add-apt-repository ppa:jonathonf/ffmpeg-3 --yes
  sudo apt-get update
  sudo apt-get dist-upgrade

  sudo apt-get --yes --force-yes install \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
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

  sudo apt-get build-dep vlc
fi

git clone https://github.com/videolabs/libdsm.git
cd libdsm
./bootstrap
./configure
make -j$(nproc)
sudo -j$(nproc) make install
cd ..

git clone https://github.com/sahlberg/libnfs.git
cd libnfs/
cmake .
make -j$(nproc)
sudo make -j$(nproc) install
cd ..

wget http://download.videolan.org/pub/vlc/3.0.0/vlc-3.0.0.tar.xz
tar xvJf vlc-3.0.0.tar.xz
cd vlc-3.0.0

mkdir build
./configure --enable-chromecast=no --prefix=$(pwd)/build
make -j$(nproc)
make -j$(nproc) install
cd ..

wget -q https://github.com/AppImage/AppImages/raw/master/functions.sh -O ./functions.sh
chmod a+x functions.sh
. functions.sh
get_apprun

cp org.videolan.vlc.desktop vlc-3.0.0/build/
cp AppRun vlc-3.0.0/build/
cp  vlc-3.0.0/build/share/icons/hicolor/256x256/apps/vlc.png  vlc-3.0.0/build/
mkdir -p vlc-3.0.0/build/usr
mv vlc-3.0.0/build/bin vlc-3.0.0/build/usr/
mv vlc-3.0.0/build/include vlc-3.0.0/build/usr/
mv vlc-3.0.0/build/lib vlc-3.0.0/build/usr/
mv vlc-3.0.0/build/share vlc-3.0.0/build/usr/

wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod a+x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage vlc-3.0.0/build/
