FROM ubuntu:18.04

RUN apt update
RUN apt install -y iproute2 gcc g++ net-tools libssl-dev flex bison libselinux1 xterm autoconf libtool build-essential screen pax gawk python3 python3-pexpect python3-pip python3-git python3-jinja2 xz-utils debianutils iputils-ping
RUN apt install -y texinfo zlib1g
RUN apt install -y zlib1g-dev
RUN apt install -y gcc-multilib
RUN apt install -y ncurses-dev
RUN dpkg --add-architecture i386
RUN apt update
RUN apt install -y zlib1g:i386 zlib1g-dev:i386
RUN apt install -y rsync
ARG DEBIAN_FRONTEND=noninteractive
RUN apt install -y expect
RUN apt install -y locales
RUN locale-gen en_US.UTF-8
RUN update-locale
RUN apt install -y cpio

RUN useradd -ms /bin/bash peta
USER peta

COPY ./petalinux-v2020.1-final-installer.run /home/peta/petalinux-v2020.1-final-installer.run
COPY ./install.exp /home/peta/install.exp
COPY ./myd_czu3eg_core.bsp /home/peta/myd_czu3eg_core.bsp
COPY ./install.sh /home/peta/install.sh
WORKDIR /home/peta

RUN expect install.exp  ARG DEBIAN_FRONTEND=noninteractive
RUN ./install.sh
