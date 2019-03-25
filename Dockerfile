# Build a docker image that's ready to build ceph

# some dependencies are only in edge, TODO build for 3.9 later too
FROM alpine:edge

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

RUN apk add abuild bash build-base ccache cmake coreutils git m4 sudo ; \
  apk upgrade

# Do all the build stuff that abuild requires
# https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package
RUN addgroup build ; \
  adduser -D -G build build ; \
  adduser build abuild ; \
  echo "%abuild ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers ; \
  chgrp abuild /var/cache/distfiles ; \
  chmod g+w /var/cache/distfiles

USER build

# enable ccache because we're going to need it
ENV PATH=/usr/lib/ccache/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /home/build/main/ceph
