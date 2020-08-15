# Build a docker image that's ready to build packages

# some dependencies are only in edge, TODO build for stable releases later too
FROM alpine:edge

# RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

RUN apk add bash alpine-conf alpine-sdk ccache cmake coreutils m4 sudo ; \
  apk upgrade -a

# Do all the build stuff that abuild requires
# https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package
RUN addgroup build ; \
  adduser -D -G build build ; \
  adduser build abuild ; \
  echo "%abuild ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers ; \
  chgrp abuild /var/cache/distfiles ; \
  chmod g+w /var/cache/distfiles

USER build

WORKDIR /home/build

ENV USE_CCACHE=true

ENTRYPOINT ["/home/build/entrypoint.sh"]
