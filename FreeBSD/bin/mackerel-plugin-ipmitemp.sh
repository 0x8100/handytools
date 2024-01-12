#!/bin/sh

# mackerel-plugin-ipmitemp.sh
#   Get the temperature inside the server using ipmitool,
#   and then sends it to Mackerel as custom metric item.
#
# LICENSE
#
# Copyright (C) 2023 0x8100 https://github.com/0x8100
# This file is licensed under WTFPL Version 2
# See http://www.wtfpl.net/ for more details.
#
# NOTES
# 
# * The script requires ipmitool and gawk
# * Kernel Module "ipmi.ko" must be loaded for ipmitool
#
# USAGE
#
# Place this script into /usr/local/bin/mackerel-plugin-ipmitemp.sh, 
# and then Put the following lines into your mackerel-agent.conf:
# ---
# [plugin.metrics.ipmitemp]
# command = "/usr/local/bin/mackerel-plugin-ipmitemp.sh"
# ---

set -ue
PATH="$PATH:/usr/local/bin"
metric_name="ipmi.temp."
epoch=$(date '+%s')

ipmitool sensor | gawk -v NAME=$metric_name -v EPOCH=$epoch -F "|" '{
         gsub(/ /, "", $0);         # remove whitespaces
         gsub(/^[0-9]+-/, "", $1);  # remove "XX-" from the name (cf. 01-CPU...) 
         if($3 == "degreesC")
               print NAME $1 "\t" $2 "\t" EPOCH
}'
