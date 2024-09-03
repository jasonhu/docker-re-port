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
- 最佳解决方案，phyllisstein/port-forward:latest, 使用socat做转发
``` shell
docker run --restart always -d -e REMOTE_HOST=nginx -e REMOTE_PORT=80 -p 80:80 phyllisstein/port-forward:latest
```
- 第一种解决方案：tcptunnel，mattsmc/docker-containers:tcptunnel
```shell
docker run --restart always -d -p 80:80 mattsmc/docker-containers:tcptunnel /root/tcptunnel/tcptunnel --local-port=80 --remote-port=80 --remote-host=nginx --log --stay-alive
```
- 第二种解决方案:port-forward，port-forward
```shell
docker run --restart always -d -e REMOTE_HOST=nginx -e REMOTE_PORT=80 -p 80:80 port-forward
```

## 技术实现
- 在docker中，转发的主机，可以通过`容器名字`和`containerid`，作为主机的名字解析到ip
- 确保新的容器，和需要通讯的容器，在同一个`容器网络`中，如果不制定网络，docker run的容器，都在`bridge`网络中
### 技术选择
- 使用 socat 通用工具做转发，封装为容器，7.1M，phyllisstein/port-forward:latest
- 使用 https://github.com/vakuum/tcptunnel，c编写，性能会比较好，支持命令行
- 使用 https://github.com/nuttt/mapport nodejs编写的
- 使用 https://github.com/HirbodBehnam/PortForwarder go编写，性能较好，配置文件方案