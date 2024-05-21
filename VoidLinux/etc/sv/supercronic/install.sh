#!/usr/bin/env bash

SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64"

if [[ `whoami` != root ]; then
    echo "Please run as root. aborting" > /dev/stderr
    exit 1
fi

if ! which wget >& /dev/null; then
    echo "wget command not found. aborting" > /dev/stderr
    exit 2
fi

function rm_tmpfile {
    [[ -f "$tmpfile" ]] && rm -f "$tmpfile"
}
tmpfile=$(mktemp)
trap rm_tmpfile EXIT
trap 'trap - EXIT; rm_tmpfile; exit -1' INT PIPE TERM

wget -O $tmpfile $SUPERCRONIC_URL

install -m 0755 -o root -g root $tmpfile /usr/local/bin/supercronic
install -m 0755 -o root -g root ../crontab /etc/crontab

for n in hourly daily weekly monthly; do
    install -m 0755 -o root -g root -d /etc/cron.$n
done

install . -m 0755 -o root -g root /etc/sv/supercronic
