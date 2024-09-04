FROM alpine:latest

# 定义构建时变量
ARG DEF_REMOTE_PORT=80
ARG DEF_LOCAL_PORT=80

# 设置环境变量
ENV REMOTE_PORT=${DEF_REMOTE_PORT} LOCAL_PORT=${DEF_LOCAL_PORT}

# 安装基础包
RUN echo "Installing base packages" \
    && apk add --update --no-cache socat ca-certificates bind-tools \
    && echo "Removing apk cache" \
    && rm -rf /var/cache/apk/

# 设置容器启动命令
CMD ["/bin/sh", "-c", "socat tcp-listen:$LOCAL_PORT,reuseaddr,fork tcp:$REMOTE_HOST:$REMOTE_PORT & pid=$! && trap \"kill $pid\" SIGINT && echo \"Socat started listening on $LOCAL_PORT: Redirecting traffic to $REMOTE_HOST:$REMOTE_PORT ($pid)\" && wait $pid"]
