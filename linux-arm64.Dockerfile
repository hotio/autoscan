FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan && \
    chmod 755 "/autoscan/autoscan"

FROM ghcr.io/hotio/base@sha256:cf17769449424dcb6790dbbf89629e81d87d9a8b864df93b84adcbc61375b943

EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan

COPY root/ /
