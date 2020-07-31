#!/bin/bash

if [[ ${1} == "checkservice" ]]; then
    SERVICE="http://service:3030/triggers/:sonarr"
    currenttime=$(date +%s); maxtime=$((currenttime+60)); while (! curl -fsSL ${SERVICE} > /dev/null) && [[ "$currenttime" -lt "$maxtime" ]]; do sleep 1; currenttime=$(date +%s); done
    curl -fsSL -u "hotio:droneci" ${SERVICE} > /dev/null
elif [[ ${1} == "checkdigests" ]]; then
    mkdir ~/.docker && echo '{"experimental": "enabled"}' > ~/.docker/config.json
    image="hotio/base"
    tag="alpine"
    manifest=$(docker manifest inspect ${image}:${tag})
    [[ -z ${manifest} ]] && exit 1
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-amd64.Dockerfile && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm" and .platform.os == "linux").digest')   && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-arm.Dockerfile   && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-arm64.Dockerfile && echo "${digest}"
else
    version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/cloudbox/autoscan/releases" | jq -r .[0].tag_name | sed s/v//g)
    [[ -z ${version} ]] && exit 1
    sed -i "s/{AUTOSCAN_VERSION=[^}]*}/{AUTOSCAN_VERSION=${version}}/g" .drone.yml
    echo "##[set-output name=version;]${version}"
fi
