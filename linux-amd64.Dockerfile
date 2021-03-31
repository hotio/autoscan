FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan && \
    chmod 755 "/autoscan/autoscan"

FROM ghcr.io/hotio/base@sha256:50325a75bc078960c5b381da3a508556f44d4b3b949469307b1a25a695a6e6fa

EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan

COPY root/ /
