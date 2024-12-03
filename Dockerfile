FROM nvidia/cuda:12.0.0-base-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    build-essential \
    libx11-6 \
    gcc \
    llvm \
    cmake \
    make \
    g++ \
    libsndfile1 \
    wget \
    ninja-build \
    ffmpeg \
 && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
RUN bash ~/miniconda.sh -b -p /opt/conda
RUN rm ~/miniconda.sh

ENV PATH="${PATH}:/opt/conda/bin"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/conda/envs/mpd/lib"

COPY environment.yml app/environment.yml
COPY setup.sh /app/setup.sh

COPY deps app/deps
RUN cd /app && bash setup.sh

COPY . /app

RUN cd app && \
    /opt/conda/envs/mpd/bin/python -m pip install -e . && \
    /opt/conda/envs/mpd/bin/python -m pip install numpy==1.19.5 matplotlib==3.5.1 opencv-python-headless

RUN git config --global --add safe.directory /app

RUN useradd -rm -d /home/worker -s /bin/bash -g root -G sudo -u 1000 worker -p $(openssl passwd -1 worker)
USER 1000
