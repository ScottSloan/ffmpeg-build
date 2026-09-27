# ffmpeg-build

为 [Bili23 Downloader](https://github.com/ScottSloan/Bili23-Downloader) 定制的精简版 FFmpeg。

编译产物随 [Python-Static](https://github.com/ScottSloan/Python-Static) 的运行时一起发布，位于运行时的 `bundle/` 目录。

## 概览

| 项目 | 说明 |
| --- | --- |
| FFmpeg | 9.0.1 |
| libmp3lame | 3.100（源码包 `lame-3.100.tar.gz` 已放在仓库中） |
| 链接方式 | 静态链接，除系统库外无其他依赖 |
| 授权 | 启用了 `--enable-gpl`，产物遵循 GPL |

只保留程序需要的组件：先用 `--disable-everything` 关闭所有组件，再按需开启。同时关闭了网络、设备、自动检测外部库（`--disable-autodetect`）和 AVX-512。除 `ffmpeg` 外不生成其他程序（如 ffprobe、ffplay）。

| 组件 | 启用项 |
| --- | --- |
| 解复用器 | concat、ffmetadata、mov、mp4、flv、m4a、mp3、matroska、image2、ass |
| 复用器 | mp4、flv、mp3、m4a、flac、matroska |
| 解码器 | h264、hevc、av1、aac、flac、eac3、ac3、mjpeg、png、webp、ass |
| 编码器 | libmp3lame、flac、mjpeg、png、ass |
| 解析器 | mjpeg、h264、hevc、av1、aac、flac、ac3、eac3 |
| 比特流过滤器 | h264_mp4toannexb |
| 滤镜 | scale、format、null、copy、aresample、aformat、anull |
| 协议 | file、concat、pipe |
| 外部库 | zlib、libmp3lame |

## 支持平台

| 平台 | 构建方式 | 最低系统要求 |
| --- | --- | --- |
| Windows x64 | 本地 MSYS2 UCRT64（GCC）编译 | Windows 10 / 11；Windows 7 SP1 需安装 UCRT（KB2999226） |
| Linux amd64 / arm64 | 本地编译，全静态链接 | 不依赖 glibc，可在任意发行版运行 |
| macOS aarch64 / x86_64 | GitHub Actions 编译 | macOS 12 Monterey |

Windows 版同时用于 Windows 10 / 11 和 Windows 7。

## 编译

整体分两步：先编译静态的 libmp3lame，再编译 FFmpeg。下文用 `$PREFIX` 表示安装目录，例如 `$HOME/build/opt`。

### 1. 准备环境

**Windows（MSYS2 UCRT64 终端）**

```bash
pacman -S make diffutils mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-nasm \
    mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-zlib
```

**Linux（Debian / Ubuntu）**

```bash
sudo apt install build-essential nasm pkg-config zlib1g-dev
```

**macOS**

```bash
xcode-select --install
brew install nasm   # 仅 x86_64 需要
export MACOSX_DEPLOYMENT_TARGET=12.0

# macOS 没有 nproc 命令，下文的 $(nproc) 可替换为 $(sysctl -n hw.ncpu)
nproc() { sysctl -n hw.ncpu; }
```

### 2. 编译 libmp3lame

```bash
tar -xzf lame-3.100.tar.gz
cd lame-3.100

./configure \
    --prefix=$PREFIX/lame-3.100 \
    --disable-shared \
    --disable-frontend \
    --enable-static \
    CFLAGS="-O3 -fomit-frame-pointer -pipe"

make -j$(nproc)
make install
```

### 3. 编译 FFmpeg

```bash
curl -LO https://ffmpeg.org/releases/ffmpeg-9.0.1.tar.xz
tar -xf ffmpeg-9.0.1.tar.xz
cd ffmpeg-9.0.1
```

执行 [`build.sh`](build.sh) 中的 `configure` 命令，并将其中的 `--prefix` 和 lame 路径改为自己的 `$PREFIX`，然后：

```bash
make -j$(nproc)
make install
```

产物为 `$PREFIX/ffmpeg/bin/ffmpeg`（Windows 下为 `ffmpeg.exe`）。

`build.sh` 中的 `--extra-ldflags='-static -static-libgcc -static-libstdc++'` 用于 Windows 和 Linux 的全静态链接。macOS 不支持 `-static`，需去掉这一项，完整参数见 [`build.yml`](.github/workflows/build.yml)。

### 4. 验证

```bash
ffmpeg -hide_banner -version
```

输出的 `configuration:` 一行应与 `build.sh` 中的参数一致。可以用以下命令检查动态库依赖，确认没有依赖系统以外的动态库：

| 平台 | 命令 |
| --- | --- |
| Windows | `ldd ffmpeg.exe`（应只包含 Windows 系统 DLL 与 UCRT） |
| Linux | `file ffmpeg`（应显示 `statically linked`） |
| macOS | `otool -L ffmpeg`（应只包含 `/usr/lib` 与 `/System` 下的库） |

## GitHub Actions

[`build.yml`](.github/workflows/build.yml) 需手动触发，分别在 macOS arm64（`macos-latest`）和 Intel（`macos-15-intel`）上编译，产物以 `ffmpeg-artifact-<arch>` 的名称上传。

## 修改组件

要支持新的格式或功能，在 `build.sh` 和 `build.yml` 中同步增加对应的 `--enable-*` 项。可以用以下命令查询可用组件的名称：

```bash
./configure --list-demuxers
./configure --list-muxers
./configure --list-decoders
./configure --list-encoders
./configure --list-filters
./configure --list-protocols
```
