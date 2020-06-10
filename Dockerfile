#FROM ubuntu:18.04
FROM debian:stable
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -u dist-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib      build-essential chrpath socat cpio python3 python3-pip python3-pexpect      xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm git mc locales apt-utils sudo

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8 

#RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
#            && locale-gen en_US.UTF-8 \
#            && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 ENV LANG en_US.utf8


RUN DEBIAN_FRONTEND=noninteractive apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
RUN groupadd -g 1000 yocto \
    &&     useradd -u 1000 -g 1000 -ms /bin/bash yocto \
    &&     usermod -a -G sudo yocto \
    &&     usermod -a -G users yocto

ENV HOME=/home/yocto
USER yocto

RUN git clone --verbose --progress --depth 1 -4 --branch dunfell git://git.yoctoproject.org/poky /home/yocto/poky
RUN mkdir -p /home/yocto/build /home/yocto/prserv
WORKDIR /home/yocto/poky
EXPOSE 8585
COPY start.sh /home/yocto/start.sh
#RUN chmod 755 /home/yocto/start.sh \
# && chown yocto.yocto /home/yocto/start.sh

VOLUME /home/yocto/prserv
VOLUME /home/yocto/build

CMD ["/home/yocto/start.sh"]
