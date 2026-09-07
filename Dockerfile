# ==================================================================
# STAGE 1: Cross-Compile Box64 for ARM64
# ==================================================================
FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS box64-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential python3 ca-certificates \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/ptitseb/box64.git /box64 \
    && mkdir /box64/build

WORKDIR /box64/build
RUN cmake .. \
    -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
    -DARM64_DYNAREC=ON -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) && make install DESTDIR=/tmp/box64-install

# ==================================================================
# STAGE 2: Base Runtime Framework (Unifying Architecture Mappings)
# ==================================================================
FROM debian:bookworm-slim AS base-runtime

ENV DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

# Core packages required across both variants
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    unzip \
    cabextract \
    xvfb \
    fluxbox \
    x11vnc \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# DYNAMIC WINE INFRASTRUCTURE:
# Both amd64 and arm64 targets require the i386 architecture added 
# to ensure wine32 libraries populate the syswow64 layout pools!
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends wine32 wine && \
    rm -rf /var/lib/apt/lists/*

# Set up working directory spaces for individual mount states
WORKDIR /avp2
RUN mkdir -p /avp2 /avp2ph

# Copy entrypoint mapping rules into root execution layer
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Declare environment variables for Unraid template parameters
ENV GAME_MODE="base"
ENV SERVER_ARGS=""

# Expose target networking layers as requested
EXPOSE 27888/udp \
       8080/tcp

# ==================================================================
# STAGE 3a: Final AMD64 Branch (Native x86_64)
# ==================================================================
FROM base-runtime AS final-amd64
ENV ARCH_EMU_PREFIX=""
ENTRYPOINT ["/entrypoint.sh"]

# ==================================================================
# STAGE 3b: Final ARM64 Branch (Emulated box64 Pipeline)
# ==================================================================
FROM base-runtime AS final-arm64
COPY --from=box64-builder /tmp/box64-install /
ENV ARCH_EMU_PREFIX="box64"
ENTRYPOINT ["/entrypoint.sh"]

# ==================================================================
# STAGE 4: Automated Router Matrix
# ==================================================================
FROM final-${TARGETARCH}
