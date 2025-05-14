ARG UBUNTU_VERSION=24.04

# ---------------------------------------
# BUILD STAGE: CUDA + Vulkan
# ---------------------------------------
FROM nvidia/cuda:12.9.0-devel-ubuntu${UBUNTU_VERSION} AS build

# Install build tools
RUN apt update && apt install -y \
    git build-essential cmake wget curl \
    libcurl4-openssl-dev python3 python3-pip python3-wheel

# Install Vulkan SDK
RUN wget -qO - https://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add - && \
    wget -qO /etc/apt/sources.list.d/lunarg-vulkan-noble.list https://packages.lunarg.com/vulkan/lunarg-vulkan-noble.list && \
    apt update -y && \
    apt-get install -y vulkan-sdk

# Build llama.cpp with CUDA and Vulkan
WORKDIR /app
COPY . .

RUN cmake -B build \
    -DGGML_NATIVE=OFF \
    -DGGML_VULKAN=1 \
    -DGGML_CUDA=1 \
    # -DLLAMA_CUDA_FORCE_DMMV=1 \
    -DLLAMA_BUILD_TESTS=OFF \
    -DGGML_BACKEND_DL=ON \
    -DGGML_CPU_ALL_VARIANTS=ON && \
    cmake --build build --config Release -j$(nproc)

# Collect libraries and binaries
RUN mkdir -p /app/lib && \
    find build -name "*.so" -exec cp {} /app/lib \;

RUN mkdir -p /app/full && \
    cp build/bin/* /app/full && \
    cp *.py /app/full && \
    cp -r gguf-py /app/full && \
    cp -r requirements /app/full && \
    cp requirements.txt /app/full && \
    cp .devops/tools.sh /app/full/tools.sh

# ---------------------------------------
# BASE RUNTIME IMAGE
# ---------------------------------------
FROM ubuntu:$UBUNTU_VERSION AS base

RUN apt-get update && apt-get install -y \
    libgomp1 \
    curl \
    libvulkan-dev \
    python3 \
    python3-pip \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

# CUDA runtime dependencies
RUN apt-get update && apt-get install -y \
    libcusparse12 libcublas12 libcublaslt12 libcurand10 \
    && apt clean -y

COPY --from=build /app/lib/ /app

# ---------------------------------------
# FULL IMAGE: CLI + Server + Tools + Python
# ---------------------------------------
FROM base AS full

COPY --from=build /app/full /app

WORKDIR /app

RUN pip install --break-system-packages --upgrade setuptools && \
    pip install --break-system-packages -r requirements.txt && \
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /tmp/* /var/tmp/* && \
    find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete && \
    find /var/cache -type f -delete

ENTRYPOINT ["/app/tools.sh"]
