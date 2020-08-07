FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG AUTOSCAN_VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${AUTOSCAN_VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan

FROM hotio/base@sha256:7a632e4f16bbbe10d2aaab75a8e7cff3ae868bb7d06e9a10182e385739f9fc7e
ENV AUTOSCAN_VERBOSITY=0
EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan
RUN chmod 755 "${APP_DIR}/autoscan"

COPY root/ /
