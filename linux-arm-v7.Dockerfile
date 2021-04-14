FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan && \
    chmod 755 "/autoscan/autoscan"

FROM ghcr.io/hotio/base@sha256:6fa9179cf9aa06dd0d03645fb5920bf2fa7edf73e3505f34b59ecfcf7340a2c6

EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan

COPY root/ /
