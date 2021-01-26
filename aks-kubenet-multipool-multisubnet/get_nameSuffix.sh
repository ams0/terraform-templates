#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "RGNAME=\(.rg_name) AKSNAME=\(.aks_name)"')"


nodeResourceGroup=`az aks show -g $RGNAME -n $AKSNAME --query nodeResourceGroup -o tsv`
rtId=`az network route-table list -g $nodeResourceGroup --query "[0].id" -o tsv`
nameSuffix=`echo $rtId | sed -e 's/\(^.*-\)\(.*\)\(-.*$\)/\2/'`

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg nameSuffix "$nameSuffix" '{"nameSuffix":$nameSuffix}'