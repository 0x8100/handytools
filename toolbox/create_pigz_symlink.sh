#!/usr/bin/env bash
set -eu

# require root privilege
if [ $(id -r -u) != 0 ]; then
    echo "Please run as root. aborted" > /dev/stderr
    exit 1
fi

# create_symlink(alternative_bin std_bin)
#   --> ln -s /usr/bin/$alternative_bin /usr/local/bin/$std_bin
function create_symlink() {
    if [ -x /usr/bin/$1 ]; then
        [ -e /usr/local/bin/$2 ] && rm /usr/local/bin/$2
        ln -sv /usr/bin/$1 /usr/local/bin/$2
    fi
}

# NOTE: In xz 5.5 or newer, multi-thread compression is 
#       supported and enable at default.

create_symlink lbzip2 bzip2
create_symlink lbzip2 bzcat
create_symlink lbzip2 bunzip2
create_symlink pigz gunzip
create_symlink pigz gzip
create_symlink pigz zcat
create_symlink zcat pigz
