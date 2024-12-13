#!/usr/bin/env bash
set -eu

# require root privilege
if [ $(id -r -u) != 0 ]; then
    echo "Please run as root. aborted" > /dev/stderr
    exit 1
fi

# create_symlink(paralell_bin std_bin)
#   --> ln -s /usr/bin/$paralell_bin ./std/bin
function create_symlink() {
    if [ -x /usr/bin/$1 ]; then
        echo "create symlink /usr/bin/$1 --> $2"
        ln -s /usr/bin/$1 $2
    fi
}

pushd /usr/local/bin > /dev/null

create_symlink lbzip2 bzip2
create_symlink lbzip2 bzcat
create_symlink lbzip2 bunzip2
create_symlink pigz gunzip
create_symlink pigz gzip
create_symlink pigz zcat
create_symlink zcat pigz
create_symlink pixz xz

popd > /dev/null
