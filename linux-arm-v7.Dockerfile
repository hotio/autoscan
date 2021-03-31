FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan && \
    chmod 755 "/autoscan/autoscan"

FROM ghcr.io/hotio/base@sha256:411bf1c3c08e452c2c8692ddde636b0099fbd3cead53846c096a5014fd57f908

EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan

COPY root/ /
