FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan

FROM hotio/base@sha256:7bfee9c33fd5ee64bb7b8842dba5031eb246d2d0cad19fd087524468e3c57532
ENV AUTOSCAN_VERBOSITY=0
EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan
RUN chmod 755 "${APP_DIR}/autoscan"

COPY root/ /
