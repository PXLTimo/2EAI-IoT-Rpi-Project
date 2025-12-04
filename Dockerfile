# This ensures the build steps run on x86 even if output is ARM
FROM --platform=$BUILDPLATFORM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && apt-get install -y \
    tzdata \
    vim \
    build-essential \
    git \
    cmake \
    net-tools \
    gdb \
    clang \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
