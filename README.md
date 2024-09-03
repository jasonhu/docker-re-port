# docker-re-port
re publish docker port for docker, do not need STOP container and docker.


## 问题背景
- 如果你运行了一个容器
```shell
docker run -d --name nginx nginx
```
- 这个时候，你本地执行 `curl http://localhost:80/` 是失败的
- 当你想将这个nginx容器中的80端口，映射到本地主机的80端口的时候
  - **你必须停止这个容器，重新运行命令**
```shell
# 停止nginx容器
docker stop nginx
# 删除nginx容器
docker rm ngiinx
# 重新启动nginx容器，并且指定端口映射
docker run -d --name nginx -p 80:80 nginx
```
- 当你重新启动nginx容器后，你在本地主机才可以
```shell
# 现在可以成功了
curl http://localhost:80/
```

## 我们需要不停止nginx容器，也需要将nginx容器的80端口，映射到本地主机的80端口

## 解决方案，启动一个新容器，绑定本地主机的80端口，将端口的请求，转发给nginx的内部ip的80端口

