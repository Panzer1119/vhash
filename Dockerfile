FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    libopencv-dev \
    libavformat-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavutil-dev \
    libswscale-dev \
    libfftw3-dev \
    libsqlite3-dev \
    libspdlog-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .
RUN rm -rf /src/build /src/bin /src/lib

# Ubuntu 24.04 ships FFmpeg 5+/6.x headers; enable FFmpeg 5+ code path.
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DFFMPEG5=ON \
    -DCMAKE_C_FLAGS="-O2 -ffile-prefix-map=/src=. -fdebug-prefix-map=/src=." \
    -DCMAKE_CXX_FLAGS="-O2 -ffile-prefix-map=/src=. -fdebug-prefix-map=/src=." \
    && cmake --build build --parallel \
    && strip /src/bin/vhash \
    && install -D -m 0755 /src/bin/vhash /out/vhash

FROM scratch AS artifact
COPY --from=build /out/vhash /vhash
