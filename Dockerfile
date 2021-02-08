FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update --quiet && apt install --no-install-recommends --yes \
            patch \
            sudo \
            tzdata

ADD . /mnt/vm
RUN /mnt/vm/install.sh
