#!/usr/bin/env bash

set -eu

MACKEREL_AGENT_URL='https://github.com/mackerelio/mackerel-agent/releases/latest/download/mackerel-agent_linux_amd64.tar.gz'

if [[ `whoami` != root ]]; then
    echo "Please run as root. aborting" > /dev/stderr
    exit 1
fi

if ! which curl >& /dev/null; then
    echo "curl command not found. aborting" > /dev/stderr
    exit 2
fi

# Create working directory
TMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Install service
curl -sL "$MACKEREL_AGENT_URL" | tar -zx -f - -C "$TMP_DIR/" mackerel-agent_linux_amd64/mackerel-agent{,.conf}
install -o root -g root -m 0755 -D "$TMP_DIR/mackerel-agent_linux_amd64/mackerel-agent" \
	/usr/local/sbin/mackerel-agent
install -o root -g root -m 0644 -D "$TMP_DIR/mackerel-agent_linux_amd64/mackerel-agent.conf" \
	/etc/mackerel-agent/mackerel-agent.conf
cp -r "$(dirname "$(readlink -f "$BASH_SOURCE")")" /etc/sv/mackerel-agent

echo 'mackerel-agent installation complete.'
echo 'To enable, type `sudo ln -s /etc/sv/mackerel-agent /var/service/mackerel-agent`'

