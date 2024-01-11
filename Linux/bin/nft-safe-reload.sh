#!/usr/bin/env bash

# Safely loads nftable rulesets
# Based on a script written by Sanjuro E.

### LICENSE WARNING #######################################
# This file has a reference source, so the contents of
# the LICENSE file (at the top of the repository) are
# **NOT** applied.
# https://sanjuroe.dev/nft-safe-reload
###########################################################

#
# Default variables
#

TIMEOUT=10
SAVED_RULES=$(mktemp)
RULES="/etc/nftables.conf"
trap "rm $SAVED_RULES" EXIT

#
# Functions
#

save() {
	echo "flush ruleset" > $SAVED_RULES
	nft list ruleset    >> $SAVED_RULES
}

check () {
	nft -c -f $RULES
}

apply() {
	nft -f $RULES
}

restore() {
	nft -f $SAVED_RULES
}

read_yesno() {
	read -t $TIMEOUT yn 2> /dev/null

	case "$yn" in
	y|Y)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

#
# Parse cmdline
#

usage() {
	cat <<EOM
Usage: $(basename "$0") [OPTION] [FILE]
Load nftable rulesets safely.

    -d, --default       Reload $RULES
    [FILE]              A nft script what can be read with nft -t

    Either -d or FILE must be specified.

EOM
}

if (( $# != 1 )); then
	usage > /dev/stderr
	exit 1
fi

case "$1" in
-h|--help)
	usage
	exit 1
	;;
-d|--default)
	;;
-*)
	usage
	exit 1
	;;
*)
	RULES=$1
	;;
esac

#
# main routine
#

if (( $EUID != 0 )); then
	echo "please run as root. aborting" > /dev/stderr
	exit 1
fi

if ! which nft &> /dev/null; then
	echo "nft command has not found. aborting" > /dev/stderr
	exit 1
fi

if ! check; then
	echo "Failed to parse script. aborting" > /dev/stderr
	exit 1
fi

if ! save; then
	echo "Failed to save current settings. aborting" > /dev/stderr
	exit 1
fi

echo    "The script is going to update nftables with rules written in $RULES"
echo -n "--> Do you want to continue? [y/N] "
if ! read_yesno; then
	echo "Aborted by user (or maybe timed out)"
	exit 1
fi

if apply; then
	echo    "Done. rollback timer has started (${TIMEOUT}s)"
	echo -n "--> Do you want to accept the new nftables configuration? [y/N] "
	if read_yesno; then
		echo "New configuration has been accepted."
	else
		restore
		echo "New configuration has been rejected and the old one restored."
		exit 2
	fi
fi
