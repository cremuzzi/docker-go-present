FROM golang:1.17-alpine3.14 as base
ARG TOOLS_VERSION=v0.1.7
ENV CGO_ENABLED=0
ENV GOARCH=amd64
ENV GOOS=linux
RUN  adduser -u 1000 -D present \
  && go install golang.org/x/tools/...@${TOOLS_VERSION} \
  && mkdir -p /var/lib/present/ \
  && mv /go/pkg/mod/golang.org/x/tools@${TOOLS_VERSION}/cmd/present/templates /var/lib/present/templates \
  && mv /go/pkg/mod/golang.org/x/tools@${TOOLS_VERSION}/cmd/present/static /var/lib/present/static
USER present

# stage prod
FROM scratch as prod
LABEL maintainer="Carlos Remuzzi carlosremuzzi@gmail.com"
LABEL org.label-schema.description="present"
LABEL org.label-schema.name="present"
LABEL org.label-schema.schema-version="1.0"
COPY --from=base /etc/passwd /etc/passwd
COPY --from=base /go/bin/present /usr/bin/present
COPY --from=base /var/lib/present /var/lib/present
WORKDIR /talk
USER present
EXPOSE 3999
CMD ["present","-base","/var/lib/present","-http","0.0.0.0:3999"]
