#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [[ `whoami` == root ]]; then
    echo 'Please run as general user, not root. aborting' > /dev/stderr
    exit 1
fi

if [[ "$(command -v etserver 2>/dev/null)" != /home/linuxbrew/.linuxbrew/bin/etserver ]] || \
              [[ "$(stat -c %U "$(command -v etserver 2>/dev/null)")" != "$(id -un)" ]]; then
    echo 'This script requires etserver, which is installed via linuxbrew and that you own. aborting' > /dev/stderr
    exit 1
fi

if [[ ! -d "$HOME/service" ]]; then
    echo "This script requires user-owned SVDIR at $HOME/service. aborting" > /dev/stderr
    exit 2
fi

# Install default settings for etserver
install -m 0644 "$HERE/et.cfg.default" /home/linuxbrew/.linuxbrew/etc/et.cfg

# Install service
cp -r $HERE $HOME/service/etserver

echo 'etserver installation has completed.'
echo 'waiting for upcoming...'
sleep 1
SVDIR=$HOME/service vsv
