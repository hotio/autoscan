ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_ARM64

FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan && \
    chmod 755 "/autoscan/autoscan"


FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_ARM64}

VOLUME ["${CONFIG_DIR}"]

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan

COPY root/ /
RUN chmod -R +x /etc/cont-init.d/ /etc/services.d/
