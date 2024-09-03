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

## 我们需要不停止nginx容器，也要将nginx容器的80端口，映射到本地主机的80端口
- 主流办法1：停止旧容器，重新启动新容器并指定-p参数
- 主流办法2：找到nginx容器定义文件，修改定义文件，停止容器，并重启docker引擎，重启容器，参考：https://github.com/williamclarkmcbride/DockerPortRemapper

## 新解决方案，启动一个新容器，绑定本地主机的80端口，将端口的请求，转发给nginx的内部ip的80端口
- 第一种解决方案：tcptunnel
```shell
docker run --restart always -d -p 80:80 mattsmc/docker-containers:tcptunnel /root/tcptunnel/tcptunnel --local-port=80 --remote-port=80 --remote-host=nginx --log --stay-alive
```
- 第二种解决方案:port-forward
```shell
docker run --restart always -d -e REMOTE_HOST=nginx -e REMOTE_PORT=80 -p 80:80 port-forward
```

## 技术实现
- 使用 https://github.com/vakuum/tcptunnel，可以启动一个命令，将tcp端口，转发给其他主机的某个端口
- 在docker中，转发的主机，可以通过名字和containerid，作为主机的名字解析到ip
- 使用 https://github.com/nuttt/mapport
