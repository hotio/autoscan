FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan && \
    chmod 755 "/autoscan/autoscan"

FROM ghcr.io/hotio/base@sha256:2a66be43f9e6b8cd54f188f29df8290e60d9882875de7ead42336f6814749a02

EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan

COPY root/ /
