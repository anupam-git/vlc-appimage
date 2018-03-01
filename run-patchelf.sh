find ./$VLC_VERSION/build/usr/lib/vlc/ -maxdepth 1 -name "lib*.so*" -exec patchelf --set-rpath '$ORIGIN/../' {} \;
find ./$VLC_VERSION/build/usr/lib/vlc/plugins/ -name "lib*.so*" -exec patchelf --set-rpath '$ORIGIN/../../:$ORIGIN/../../../' {} \;
