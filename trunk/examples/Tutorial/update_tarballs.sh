#!/bin/sh

for x in */ ; do
  tar cf - "$x" | gzip > "${x%/}.tar.gz"
done

