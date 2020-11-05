# docker搭建可构建android的jenkins环境

在**docker-compose.yml**文件目录下，执行如下代码构建jenkins下的android CI/CD环境：

```shell
docker-compose up -d --build
```

停止jenkins服务：

```shell
docker-compose down
```

重新启动：

```sh
docker-compose up -d
```

通过terminal进入container内：

```
docker exec -it contianer /bin/bash
```

通过如下地址访问jenkins:

```http
localhost:8080
```

在jenkins内创建pipeline project配置如下gitlab代码库查看pipeline：

```http
https://git.thoughtworks.net/lizhao/jenkins-test-project.git
```

> 没有此代码库权限的同学请联系 lizhao@thoughtworks.com