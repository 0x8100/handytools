#! /usr/local/bin/bash

# mackerel-plugin-zfs-check.sh
#   Checks the status of the pool specified in the script,
#   and sends it to Mackerel as a custom check item
#
# LICENSE
#
# This file is licensed under WTFPL Version 2
# See the LICENSE file for more details:
# https://github.com/0x8100/handytools/blob/main/LICENSE
#
# USAGE
#
# Place this script into /usr/local/bin/mackerel-plugin-zfs-check.sh,
# and then Put the following lines into your mackerel-agent.conf:
# ---
# [plugin.checks.zroot]
# command = "/usr/local/bin/mackerel-plugin-zfs-check.sh"
# ---

# Specify the pool name you want to check
pool="zroot"

# Set default status to 3 (Unkwn)
poolStatus=3

# Check the status
poolStatus=$(/sbin/zpool status ${pool} | awk '{ 
    if($0 ~ /state: (UNAVAIL|FAULTED$)/) print "FAULTED"
    else if($0 ~ /state: DEGRADED$/) print "DEGRADED"
    else if($0 ~ /state: ONLINE$/) print "OK"
    else if($0 ~ /state: [A-Z]+$/) print "UNKNOWN"
    }')

# Code returned to mackerel-agent is:
# 0 (OK)        : Health (ONLINE)
# 1 (Warn)      : Health (DEGRADED)
# 2 (Crit)      : Health (UNAVAIL or FAULTED)
# 3 (Unkwn)     : others
case $poolStatus in 
    "OK" )
        exit 0;;
    "DEGRADED" )
        exit 1;;
    "FAULTED" )
        exit 2;;
    * ) 
        exit 3;;
esac