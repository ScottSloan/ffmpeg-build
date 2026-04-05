export ARCH=x86_64

./configure \
--prefix=/home/scott/build/opt/ffmpeg \
--disable-doc \
--disable-shared \
--disable-everything \
--disable-programs \
--disable-swscale \
--disable-filters \
--disable-swresample \
--disable-avx512 \
--disable-network \
--disable-avdevice \
--disable-autodetect \
--enable-demuxer='concat,ffmetadata,mov,mp4,flv,m4a,mp3,matroska' \
--enable-muxer='mp4,flv,mp3,m4a,flac,matroska' \
--enable-decoder='h264,hevc,av1,aac,flac,eac3,ac3,mjpeg,png,webp' \
--enable-encoder='libmp3lame,flac' \
--enable-parser='mjpeg,h264,hevc,av1,aac,flac,ac3,eac3' \
--enable-static \
--enable-small \
--enable-ffmpeg \
--enable-protocol='file,concat' \
--enable-zlib \
--enable-libmp3lame \
--enable-gpl \
--extra-ldflags='-static -static-libgcc -static-libstdc++' \
--extra-ldflags="-L/home/scott/build/opt/lame-3.100/lib" \
--extra-cflags="-I/home/scott/build/opt/lame-3.100/include" \

