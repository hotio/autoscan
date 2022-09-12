#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    export DOCKER_CLI_EXPERIMENTAL=enabled
    upstream_image=$(jq -r '.upstream_image' < VERSION.json)
    upstream_tag=$(jq -r '.upstream_tag' < VERSION.json)
    manifest=$(docker manifest inspect "${upstream_image}:${upstream_tag}")
    [[ -z ${manifest} ]] && exit 1
    upstream_digest_amd64=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest')
    upstream_digest_arm64=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm64" and .platform.os == "linux").digest')
    version_json=$(cat ./VERSION.json)
    jq '.upstream_digest_amd64 = "'"${upstream_digest_amd64}"'" | .upstream_digest_arm64 = "'"${upstream_digest_arm64}"'"' <<< "${version_json}" > VERSION.json
elif [[ ${1} == "tests" ]]; then
    echo "List installed packages..."
    docker run --rm --entrypoint="" "${2}" apk -vv info | sort
    echo "Check if app works..."
    app_url="http://localhost:3030/triggers/sonarr"
    docker run --network host -d --name service "${2}"
    currenttime=$(date +%s); maxtime=$((currenttime+60)); while (! curl -fsSL --header "Content-Type: application/json" --request POST --data '{"eventType": "Test","series": {"id": 1,"title": "Test Title","path": "C:\\testpath","tvdbId": 1234},"episodes": [{"id": 123,"episodeNumber": 1,"seasonNumber": 1,"title": "Test title","qualityVersion": 0}]}' "${app_url}" > /dev/null) && [[ "$currenttime" -lt "$maxtime" ]]; do sleep 1; currenttime=$(date +%s); done
    curl -fsSL --header "Content-Type: application/json" --request POST --data '{"eventType": "Test","series": {"id": 1,"title": "Test Title","path": "C:\\testpath","tvdbId": 1234},"episodes": [{"id": 123,"episodeNumber": 1,"seasonNumber": 1,"title": "Test title","qualityVersion": 0}]}' "${app_url}" > /dev/null
    status=$?
    echo "Show docker logs..."
    docker logs service
    exit ${status}
elif [[ ${1} == "screenshot" ]]; then
    app_url="http://localhost:3030/triggers/manual"
    docker run --rm --network host -d --name service "${2}"
    currenttime=$(date +%s); maxtime=$((currenttime+60)); while (! curl -fsSL "${app_url}" > /dev/null) && [[ "$currenttime" -lt "$maxtime" ]]; do sleep 1; currenttime=$(date +%s); done
    docker run --rm --network host --entrypoint="" -u "$(id -u "$USER")" -v "${GITHUB_WORKSPACE}":/usr/src/app/src zenika/alpine-chrome:with-puppeteer node src/puppeteer.js
    exit 0
else
    version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/cloudbox/autoscan/releases/latest" | jq -r .tag_name | sed s/v//g)
    [[ -z ${version} ]] && exit 1
    old_version=$(jq -r '.version' < VERSION.json)
    changelog=$(jq -r '.changelog' < VERSION.json)
    [[ "${old_version}" != "${version}" ]] && changelog="https://github.com/cloudbox/autoscan/compare/v${old_version}...v${version}"
    version_json=$(cat ./VERSION.json)
    jq '.version = "'"${version}"'" | .changelog = "'"${changelog}"'"' <<< "${version_json}" > VERSION.json
fi
