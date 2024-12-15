#!/usr/bin/env bash

set -eu

SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64"

if [[ `whoami` != root ]]; then
    echo "Please run as root. aborting" > /dev/stderr
    exit 1
fi

if ! which curl >& /dev/null; then
    echo "curl command not found. aborting" > /dev/stderr
    exit 2
fi

function rm_tmpfile {
    [[ -f "$tmpfile" ]] && rm -f "$tmpfile"
}
tmpfile=$(mktemp)
trap rm_tmpfile EXIT
trap 'trap - EXIT; rm_tmpfile; exit -1' INT PIPE TERM

# Downlaod supercronic
curl -o $tmpfile $SUPERCRONIC_URL
install -m 0755 -o root -g root $tmpfile /usr/local/bin/supercronic

# Install default crontab and periodic script directories
install -m 0755 -o root -g root ../../crontab /etc/crontab
for n in hourly daily weekly monthly; do
    install -m 0755 -o root -g root -d /etc/cron.$n
done

# Install service
cp -r . /etc/sv/supercronic

echo 'Supercronic installation complete.'
echo 'To enable, type `sudo ln -s /etc/sv/supercronic /var/service/supercronic`'
