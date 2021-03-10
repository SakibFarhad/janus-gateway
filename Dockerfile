FROM ubuntu:20.04 AS build

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git libmicrohttpd-dev libjansson-dev libssl-dev libsrtp2-dev libsofia-sip-ua-dev \
                       libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev libconfig-dev \
                       pkg-config gengetopt libtool automake gtk-doc-tools cmake ninja-build python3-pip wget && \
    apt-get clean -y

RUN python3 -m pip install meson

# Install libnice
RUN mkdir /opt/dependency -p && \ 
    git clone https://gitlab.freedesktop.org/libnice/libnice && \
    cd libnice && \
    meson builddir && \
    ninja -C builddir && \
    ninja -C builddir install

# Install libsrtp
RUN cd /opt/dependency && \
    wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz && \
    tar xfv v2.2.0.tar.gz && cd libsrtp-2.2.0 && \
    ./configure --prefix=/usr --enable-openssl && \
    make shared_library -j && make install 

# Install usrsctp
RUN cd /opt/dependency && \
    git clone https://github.com/sctplab/usrsctp && \
    cd usrsctp && ./bootstrap && ./configure --prefix=/usr && \
    make -j && make install

# Install libwebsockets
RUN cd /opt/dependency && \
    git clone https://github.com/warmcat/libwebsockets.git && \
    cd libwebsockets && git checkout v3.2-stable && \
    mkdir build && cd build && \
    cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
    make -j && make install

