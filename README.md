# ffmpeg-build
Bili23 Downloader 定制版 ffmpeg

## 编译流程
### 先编译 libmp3lame
```bash
./configure \
--prefix=/d/FFmpeg/lame-3.100/build \
--disable-shared \
--disable-frontend \
--enable-static \
```

### 再编译 ffmpeg
参考 `build.sh`
