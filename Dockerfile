FROM ubuntu:24.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       ca-certificates git python3 procps locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV LANG=en_US.UTF-8

RUN groupadd -g 2000 yocto && useradd -u 2000 -g 2000 -ms /bin/bash yocto

RUN mkdir -p /home/yocto/pr_hash_serv-volume-wrynose && chown -R yocto:yocto /home/yocto/pr_hash_serv-volume-wrynose
RUN chmod -R a+rw /home/yocto/pr_hash_serv-volume-wrynose
VOLUME /home/yocto/pr_hash_serv-volume-wrynose

ENV HOME=/home/yocto
USER yocto
WORKDIR /home/yocto/

# wrynose uses bitbake 2.18; poky has no wrynose branch, and the servers only need bitbake itself.
ARG BITBAKE_BRANCH=2.18
RUN git clone --depth 1 --branch ${BITBAKE_BRANCH} https://git.openembedded.org/bitbake /home/yocto/bitbake
COPY start.sh /home/yocto/start.sh

# own ports, different from the scarthgap image (8585-8888), so both can run side by side
EXPOSE 9191
EXPOSE 9292
EXPOSE 9393
EXPOSE 9494

CMD ["/home/yocto/start.sh"]
