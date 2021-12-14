FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update --quiet --quiet && \
    apt install --no-install-recommends --quiet --yes \
            apt-utils \
            patch \
            sudo \
            tzdata

ADD . /mnt/vm
RUN /mnt/vm/install.sh
