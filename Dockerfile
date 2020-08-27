FROM golang:1.15.0-alpine3.12 AS build

ARG GOTOOLS_VERSION=v0.4.4

ENV CGO_ENABLED=0 \
    GOARCH=amd64 \
    GOOS=linux

RUN apk add --no-cache \
    && adduser -u 10001 -D present \
    && mkdir -p src/golang.org/x/ \
    && wget https://github.com/golang/tools/archive/gopls/${GOTOOLS_VERSION}.tar.gz \
    && tar -xf v0.4.4.tar.gz -C src/golang.org/x/ \
    && rm v0.4.4.tar.gz \
    && mv src/golang.org/x/tools-gopls-v0.4.4/ src/golang.org/x/tools/ \
    && cd src/golang.org/x/tools/cmd/present \
    && go build \
      -a -ldflags '-s -w -extldflags "-static"' \
      -o /go/bin/present ./...

FROM scratch as prod

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /go/bin/present /usr/bin/present
COPY --from=build /go/src/golang.org/x/tools/cmd/present/templates /var/lib/present/templates
COPY --from=build /go/src/golang.org/x/tools/cmd/present/static /var/lib/present/static

WORKDIR /talk

USER present

EXPOSE 3999

CMD ["present","-base","/var/lib/present","-http","0.0.0.0:3999"]
