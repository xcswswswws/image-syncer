FROM golang:1.19.2 as builder
WORKDIR /go/src/github.com/AliyunContainerService/image-syncer
COPY ./ ./
COPY ./image-syncer.json /etc/image-syncer/image-syncer.json
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 make

FROM alpine:latest
WORKDIR /bin/
COPY --from=builder /go/src/github.com/AliyunContainerService/image-syncer/image-syncer ./
COPY --from=builder /go/src/github.com/AliyunContainerService/image-syncer/image-syncer/image-syncer.json /etc/image-syncer/image-syncer.json
COPY --from=builder /go/src/github.com/AliyunContainerService/image-syncer/image-syncer.json /etc/image-syncer/image-syncer.json
RUN chmod +x ./image-syncer
RUN apk add -U --no-cache ca-certificates && rm -rf /var/cache/apk/* && mkdir -p /etc/ssl/certs \
  && update-ca-certificates --fresh
ENTRYPOINT ["image-syncer"]
CMD ["--config", "/etc/image-syncer/image-syncer.json","--registry","registry.cn-hangzhou.aliyuncs.com","--namespace","proficloud","--retries","10"]
