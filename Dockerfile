FROM oven/bun:1.3.11-alpine AS build

ENV LANG=C.UTF-8

RUN apk add --no-cache \
    build-base \
    cmake \
    pkgconf \
    opencv-dev \
    ffmpeg-dev \
    fftw-dev \
    sqlite-dev \
    spdlog-dev

WORKDIR /src
COPY . .
RUN rm -rf /src/build /src/bin /src/lib

# Alpine ships FFmpeg 5+/6.x headers; enable FFmpeg 5+ code path.
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DFFMPEG5=ON \
    -DCMAKE_C_FLAGS="-O2 -ffile-prefix-map=/src=. -fdebug-prefix-map=/src=." \
    -DCMAKE_CXX_FLAGS="-O2 -ffile-prefix-map=/src=. -fdebug-prefix-map=/src=." \
    && cmake --build build --parallel \
    && strip /src/bin/vhash \
    && install -D -m 0755 /src/bin/vhash /out/vhash

FROM oven/bun:1.3.11-alpine AS artifact
RUN apk add --no-cache \
    libstdc++ \
    opencv \
    ffmpeg \
    fftw \
    sqlite-libs \
    spdlog
COPY --from=build /out/vhash /usr/local/bin/vhash
ENTRYPOINT ["/usr/local/bin/vhash"]
