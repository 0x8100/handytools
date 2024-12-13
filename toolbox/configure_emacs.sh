#!/bin/sh

export MAKE=gmake
export MAKEINFO=no
export CFLAGS="-I/usr/include -I/usr/local/include -I/usr/local/include/ncurses"
export LDFLAGS="-L/usr/lib -L/usr/local/lib"
./configure \
  --with-gnutls=ifavailable \
  --without-sound \
  --without-pop \
  --without-gconf \
  --without-gsettings \
  --without-selinux \
  --without-x \
  --without-dbus \
  --prefix=$HOME/.local/emacs

