#!/usr/bin/env bash

set -eu

if [[ `whoami` != root ]]; then
    echo "Please run as root. aborting" > /dev/stderr
    exit 1
fi

if ! which curl >& /dev/null; then
    echo "curl command not found. aborting" > /dev/stderr
    exit 2
fi

# creates working directory
TMPDIR=$(mktemp -d)
cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

curl -sL 'https://github.com/mackerelio/mackerel-agent/releases/latest/download/mackerel-agent_linux_amd64.tar.gz' | tar -zx -f - -C "$TMPDIR/" mackerel-agent_linux_amd64/mackerel-agent{,.conf}
install -o root -g root -m 0755 -D "$TMPDIR/mackerel-agent_linux_amd64/mackerel-agent" \
	/usr/local/sbin/mackerel-agent
install -o root -g root -m 0644 -D "$TMPDIR/mackerel-agent_linux_amd64/mackerel-agent.conf" \
	/etc/mackerel-agent/mackerel-agent.conf
cp -r . /etc/sv/mackerel-agent

# Install service
cp -r . /etc/sv/mackerel-agent

echo 'mackerel-agent installation complete.'
echo 'To enable, type `sudo ln -s /etc/sv/mackerel-agent /var/service/mackerel-agent`'

