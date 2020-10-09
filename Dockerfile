FROM golang:1.15.2-alpine3.12 AS build

ARG GOTOOLS_VERSION=v0.5.1

ENV CGO_ENABLED=0 \
    GOARCH=amd64 \
    GOOS=linux

RUN adduser -u 10001 -D present \
    && mkdir -p src/golang.org/x/ \
    && wget https://github.com/golang/tools/archive/gopls/${GOTOOLS_VERSION}.tar.gz \
    && tar -xf ${GOTOOLS_VERSION}.tar.gz \
    && rm ${GOTOOLS_VERSION}.tar.gz \
    && mv tools-gopls-* tools-gopls \
    && cd tools-gopls/cmd/present \
    && go mod download \
    && go build \
      -a -ldflags '-s -w -extldflags "-static"' ./...

FROM scratch as prod

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /go/tools-gopls/cmd/present/present /usr/bin/present
COPY --from=build /go/tools-gopls/cmd/present/templates /var/lib/present/templates
COPY --from=build /go/tools-gopls/cmd/present/static /var/lib/present/static

WORKDIR /talk

USER present

EXPOSE 3999

CMD ["present","-base","/var/lib/present","-http","0.0.0.0:3999"]
