FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG AUTOSCAN_VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${AUTOSCAN_VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan

FROM hotio/base@sha256:ad79f26c53e2c7e1ed36dba0a0686990c503835134c63d9ed5aa7951e1b45c23

EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan
RUN chmod 755 "${APP_DIR}/autoscan"

COPY root/ /
