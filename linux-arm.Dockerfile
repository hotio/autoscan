FROM golang:alpine as builder

RUN apk add --no-cache gcc libc-dev

ARG AUTOSCAN_VERSION

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${AUTOSCAN_VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan

FROM hotio/base@sha256:fd6cef3f4f361b5def1337cfb26b796bc401cf8c07cae4ebd376f4d603a32136
ENV AUTOSCAN_VERBOSITY=0
EXPOSE 3030

COPY --from=builder /autoscan/autoscan ${APP_DIR}/autoscan
RUN chmod 755 "${APP_DIR}/autoscan"

COPY root/ /
