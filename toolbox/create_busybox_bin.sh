#!/bin/sh

set -eu

BUSYBOX="/usr/bin/busybox.static"
PREFIX="/static"

# require root privilege
if [ $(id -r -u) != 0 ]; then
    echo "Please run as root. aborted" > /dev/stderr
    exit 1
fi

if [ ! -e "$BUSYBOX" ]; then
    echo "Please install busybox-static into $BUSYBOX . aborted" > /dev/stderr
    exit 1
fi

mkdir $PREFIX
cp $BUSYBOX ${PREFIX}/busybox.static

for i in `${PREFIX}/busybox.static --list`; do
    ln ${PREFIX}/busybox.static ${PREFIX}/${i}
done

echo "busybox-static shell environment has installed into $PREFIX ."
