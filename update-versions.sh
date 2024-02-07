#!/bin/bash

version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/cloudbox/autoscan/commits/master" | jq -r .sha)
[[ -z ${version} ]] && exit 0
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${version}" \
    '.version = $version' <<< "${json}" > VERSION.json
