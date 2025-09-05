#!/usr/bin/env bash

set -eu

PREFIX="~/.local/bin"
XREMAP_URL="https://github.com/xremap/xremap/releases/download/v0.10.16/xremap-linux-x86_64-gnome.zip"

if ! which curl >& /dev/null; then
    echo "curl command not found. aborting" > /dev/stderr
    exit 2
fi

function rm_tmpfile {
    [[ -f "$tmpfile" ]] && rm -f "$tmpfile"
}
tmpfile=$(mktemp)
trap rm_tmpfile EXIT
%trap 'trap - EXIT; rm_tmpfile; exit -1' INT PIPE TERM

# Downlaod & install xremap
curl -o $tmpfile $XREMAP_URL
install -d $PREFIX
install $tmpfile $PREFIX/xremap
install -d ~/.config/xremap/
install config.yml ~/.config/xremap/config.yml

# Enable xremap without sudo
sudo gpasswd -a $(whoami) input
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/udev.conf

echo 'xremap Installation has completed, but we need RESTART to use xremap without sudo.'
echo 'type `xremap ~/.config/xremap/config.yml` to use xremap, or `cp -r {,~/}service/xremap` to run daemon mode.'

