#/bin/bash

VLC_VERSION="vlc-3.0.0"

# echo "deb http://in.archive.ubuntu.com/ubuntu/ trusty main" | tee /etc/apt/sources.list.d/trusty.list
wget https://archive.neon.kde.org/public.key -O neon.key
apt-key add neon.key
echo "deb https://archive.neon.kde.org/user/ xenial main" > /etc/apt/sources.list.d/neon.list

apt-get update
apt-get --yes install python-software-properties software-properties-common apt-transport-https ca-certificates
add-apt-repository ppa:jonathonf/ffmpeg-3 --yes
add-apt-repository universe --yes
add-apt-repository ppa:beineri/opt-qt-5.10.1-trusty
apt-get update
apt-get --yes dist-upgrade
apt-get --yes install libsystemd-dev libarchive-dev git wget curl build-essential autoconf libtool pkg-config patchelf libtasn1-3-dev libtasn1-3-bin libbsd-dev git bison qtbase5-dev qtdeclarative5-dev extra-cmake-modules plasma-framework-dev libqt5xmlpatterns5-dev qtdeclarative5-dev-tools qml-module-qtgraphicaleffects qtbase5-private-dev libqt5svg5-dev automake autopoint gettext cmake wayland-protocols protobuf-compiler libmpg123-dev libgstreamer-plugins-base1.0-dev libsystemd-dev libarchive-dev libopencv-dev 

apt-get build-dep vlc --yes

(
  git clone https://github.com/videolabs/libdsm.git
  cd libdsm
  ./bootstrap
  ./configure --prefix=/usr
  make -j$(nproc)
  make -j$(nproc) install
)

(
  git clone https://github.com/sahlberg/libnfs.git
  cd libnfs/
  cmake -DCMAKE_INSTALL_PREFIX=/usr .
  make -j$(nproc)
  make -j$(nproc) install
)

(
  export QT_SELECT=qt5
  export PATH=$PATH:/opt/qt510/bin/
  export QML_MODULES_FIND_DIRS="/opt/qt510/qml /usr/lib/x86_64-linux-gnu/qml"
  /opt/qt510/bin/qt510-env.sh
  ldconfig -c /opt/qt510/lib/ /usr/lib/x86_64-linux-gnu/
  wget http://download.videolan.org/pub/vlc/3.0.0/$VLC_VERSION.tar.xz
  tar xJf $VLC_VERSION.tar.xz
  cd $VLC_VERSION
  ./configure --enable-chromecast=no --prefix=/usr
  make -j$(nproc)
  make -j$(nproc) DESTDIR=$(pwd)/build/ install
  chmod 755 -R ./$VLC_VERSION/build
  cd build
  cp ../../org.videolan.vlc.desktop ./
  cp ./usr/share/icons/hicolor/256x256/apps/vlc.png ./
  mkdir -p ./usr/plugins/iconengines/
  cp /usr/lib/x86_64-linux-gnu/qt5/plugins/iconengines/libqsvgicon.so ./usr/plugins/iconengines/
  mkdir -p ./usr/plugins/platforms/
  cp /usr/lib/x86_64-linux-gnu/qt5/plugins/platforms/libqxcb.so ./usr/plugins/platforms/
  rm usr/lib/vlc/plugins/plugins.dat
  ./$VLC_VERSION/build/usr/lib/vlc/vlc-cache-gen ./$VLC_VERSION/build/usr/lib/vlc/plugins
)

chmod a+x ./run-patchelf.sh
VLC_VERSION=$VLC_VERSION ./run-patchelf.sh

wget "https://github.com/azubieta/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x ./linuxdeployqt-continuous-x86_64.AppImage
LINUX_DEPLOY_QT_EXCLUDE_COPYRIGHTS=true appimage-wrapper linuxdeployqt-continuous-x86_64.AppImage $VLC_VERSION/build/org.videolan.vlc.desktop -bundle-non-qt-libs
LINUX_DEPLOY_QT_EXCLUDE_COPYRIGHTS=true ARCH=x86_64 appimage-wrapper linuxdeployqt-continuous-x86_64.AppImage $VLC_VERSION/build/org.videolan.vlc.desktop -appimage

echo ""
echo "############################################################################"
echo ""

mkdir -p release

cp ./VLC_media_player*.AppImage release/
md5sum ./VLC_media_player*.AppImage > release/MD5.txt
curl --upload-file ./VLC_media_player*.AppImage https://transfer.sh/$VLC_VERSION.AppImage > release/URL
