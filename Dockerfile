FROM golang:1.19.2 as builder
WORKDIR /go/src/github.com/AliyunContainerService/image-syncer
COPY ./ ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 make

FROM alpine:latest
WORKDIR /bin/
COPY --from=builder /go/src/github.com/AliyunContainerService/image-syncer/image-syncer ./
echo "
{
    "auth": {
        "registry.hub.docker.com": {
            "username": "905447797",
            "password": "xcswswswws90",
            "insecure": true
        },
        "registry.cn-hangzhou.aliyuncs.com": {
            "username": "菲尼克斯测试账号3",
            "password": "Phoenix123"
        }
    },
    "images": {
        "registry.hub.docker.com/905447797/image-syncer": "",
        "registry.hub.docker.com/905447797/nginx": ""
    }
}
"> /etc/image-syncer/image-syncer.json
RUN chmod +x ./image-syncer
RUN apk add -U --no-cache ca-certificates && rm -rf /var/cache/apk/* && mkdir -p /etc/ssl/certs \
  && update-ca-certificates --fresh
ENTRYPOINT ["image-syncer"]
CMD ["--config", "/etc/image-syncer/image-syncer.json","--registry","registry.cn-hangzhou.aliyuncs.com","--namespace","proficloud","--retries","10"]
