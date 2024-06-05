# OpenResty Lua灰度

## 1. 部署要求
待补充

## 2. 部署

### 2.1 修改nginx配置

![](./images/01.jpeg)

### 2.2 设置管理密码
``` sh
htpasswd -b ./conf/htpasswd gray 123456
```

### 2.3 设置灰度规则

#### 2.3.1. 添加规则

``` sh 全局规则
curl --location 'http://localhost:18888/_admin' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic Z3JheToxMjM0NTY=' \
--data-urlencode 'key=user' \
--data-urlencode 'value=[
{
"path": "/hello.*",
"upstream": "gray_backend"
}
]'
```

``` sh 指定用户配置规则
curl --location 'http://localhost:18888/_admin' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic Z3JheToxMjM0NTY=' \
--data-urlencode 'key=user:username1' \
--data-urlencode 'value=[
{
"path": "/helloword",
"upstream": "gray_backend"
}
]'
```


### 2.3.2. 查询规则

全局规则
``` sh 
curl --location --request GET 'http://localhost:18888/_admin?key=user' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic Z3JheToxMjM0NTY=' 
```
指定用户的规则
``` sh 
curl --location --request GET 'http://localhost:18888/_admin?key=user:username1' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic Z3JheToxMjM0NTY=' 
```

### 2.3.2. 删除规则

删除全局规则
``` sh 
curl --location --request DELETE 'http://localhost:18888/_admin' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic Z3JheToxMjM0NTY=' \
--data-urlencode 'key=user'
```

删除指定用户的规则
``` sh 
curl --location --request DELETE 'http://localhost:18888/_admin' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic Z3JheToxMjM0NTY=' \
--data-urlencode 'key=user:username1'
```

## 3. 测试

``` sh
curl --location 'http://localhost:18888/helloword' \
--header 'x-custom-header: some_value' \
--header 'Authorization: Basic dXNlcm5hbWUxOnBhc3N3b3JkMQ=='
```