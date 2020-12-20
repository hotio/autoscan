[![GitHub Source](https://img.shields.io/badge/github-source-ffb64c?style=flat-square&logo=github&logoColor=white&labelColor=757575)](https://github.com/hotio/autoscan)
[![GitHub Registry](https://img.shields.io/badge/github-registry-ffb64c?style=flat-square&logo=github&logoColor=white&labelColor=757575)](https://github.com/orgs/hotio/packages/container/package/autoscan)
[![Docker Pulls](https://img.shields.io/docker/pulls/hotio/autoscan?color=ffb64c&style=flat-square&label=pulls&logo=docker&logoColor=white&labelColor=757575)](https://hub.docker.com/r/hotio/autoscan)
[![Discord](https://img.shields.io/discord/610068305893523457?style=flat-square&color=ffb64c&label=discord&logo=discord&logoColor=white&labelColor=757575)](https://hotio.dev/discord)
[![Upstream](https://img.shields.io/badge/upstream-project-ffb64c?style=flat-square&labelColor=757575)](https://github.com/Cloudbox/autoscan)
[![Website](https://img.shields.io/badge/website-hotio.dev-ffb64c?style=flat-square&labelColor=757575)](https://hotio.dev/containers/autoscan)

## Starting the container

Just the basics to get the container running:

```shell hl_lines="4 5 6 7 8 9 10 11 12"
docker run --rm \
    --name autoscan \
    -p 3030:3030 \
    -e PUID=1000 \
    -e PGID=1000 \
    -e UMASK=002 \
    -e TZ="Etc/UTC" \
    -e ARGS="" \
    -e DEBUG="no" \
    -e AUTOSCAN_VERBOSITY=0 \
    -e PLEX_LOGIN="" \
    -e PLEX_PASSWORD="" \
    -v /<host_folder_config>:/config \
    hotio/autoscan
```

The [highlighted](https://hotio.dev/containers/autoscan) variables are all optional, the values you see are the defaults.

If `PLEX_LOGIN` + `PLEX_PASSWORD` are not empty and the file `/config/app/plex.token` does not exist, an attempt is made to get a Plex token for Autoscan.

## Tags

| Tag                | Upstream               | Version | Build |
| -------------------|------------------------|---------|-------|
| `release` (latest) | GitHub releases        | ![version](https://img.shields.io/badge/dynamic/json?color=f5f5f5&style=flat-square&label=&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fhotio%2Fautoscan%2Frelease%2FVERSION.json) | ![build](https://img.shields.io/github/workflow/status/hotio/autoscan/build/release?style=flat-square&label=) |
| `nightly`          | Every commit to master | ![version](https://img.shields.io/badge/dynamic/json?color=f5f5f5&style=flat-square&label=&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fhotio%2Fautoscan%2Fnightly%2FVERSION.json) | ![build](https://img.shields.io/github/workflow/status/hotio/autoscan/build/nightly?style=flat-square&label=) |

You can also find tags that reference a commit or version number.

## Configuration location

Your autoscan configuration inside the container is stored in `/config/app`, to migrate from another container, you'd probably have to move your files from `/config` to `/config/app`.

## Using a secure Plex connection

If you want to keep using secure connections within Plex, but don't wanna buy your own domain and keep the connection between Autoscan and Plex inside of their Docker network. Follow the below procedure.

Go to `https://plex.tv/pms/resources.xml?includeHttps=1&X-Plex-Token=xxxxxxxxxxxxxx` (replace `xxxxxxxxxxxxxx` with your token) and look for a url that looks like `https://10-1-0-100.xxxxxxxxxxxxx.plex.direct:32400`. That url can be used in your Autoscan plex target. You should however give the Plex container a static IP if you don't wanna do this every 5 minutes.

## Executing your own scripts

If you have a need to do additional stuff when the container starts or stops, you can mount your script with `-v /docker/host/my-script.sh:/etc/cont-init.d/99-my-script` to execute your script on container start or `-v /docker/host/my-script.sh:/etc/cont-finish.d/99-my-script` to execute it when the container stops. An example script can be seen below.

```shell
#!/usr/bin/with-contenv bash

echo "Hello, this is me, your script."
```

## Troubleshooting a problem

By default all output is redirected to `/dev/null`, so you won't see anything from the application when using `docker logs`. Most applications write everything to a log file too. If you do want to see this output with `docker logs`, you can use `-e DEBUG="yes"` to enable this.
