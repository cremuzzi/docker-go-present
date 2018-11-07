FROM golang:1.11.2-alpine3.8 AS builder

RUN apk add --no-cache --virtual .build-deps git \
    && go get golang.org/x/tools/cmd/present \
    && apk del .build-deps

FROM alpine:3.8

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"

COPY --from=builder /go/bin/present /usr/local/bin/present
COPY --from=builder /go/src/golang.org/x/tools/cmd/present /var/lib/present

USER nobody

WORKDIR /home/nobody

EXPOSE 3999

CMD ["present","-base","/var/lib/present","-http","0.0.0.0:3999"]
