#!/bin/sh

for x in */ ; do
  pushd $x/* && \
  perl Makefile.PL && \
  make distclean && \
  popd && \
  tar cf - --exclude .svn "$x" | gzip > "${x%/}.tar.gz"
done

