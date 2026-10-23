FROM debian:trixie-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       ca-certificates git python3 psmisc locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV LANG=en_US.UTF-8

RUN groupadd -g 2000 yocto && useradd -u 2000 -g 2000 -ms /bin/bash yocto

RUN mkdir -p /home/yocto/pr_hash_serv-volume-scarthgap && chown -R yocto:yocto /home/yocto/pr_hash_serv-volume-scarthgap
RUN chmod -R a+rw /home/yocto/pr_hash_serv-volume-scarthgap
VOLUME /home/yocto/pr_hash_serv-volume-scarthgap

ENV HOME=/home/yocto
USER yocto
WORKDIR /home/yocto/

RUN git clone --depth 1 --branch scarthgap https://git.yoctoproject.org/poky /home/yocto/poky/
RUN ls -alh /home/yocto/poky
RUN sed -i -e "s#EXCLUSIVE#IMMEDIATE#g" /home/yocto/poky/bitbake/lib/prserv/db.py
COPY start.sh /home/yocto/start.sh

EXPOSE 8585
EXPOSE 8686
EXPOSE 8787
EXPOSE 8888

CMD ["/home/yocto/start.sh"]
