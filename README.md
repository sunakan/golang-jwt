
```
$ make up
```

別シェルで

- Token無しでprivate-ping：失敗
- Token有りでprivate-ping：成功


```
$ make curl
==================TOKEN 無し
curl -is localhost:8080/private-ping
HTTP/1.1 401 Unauthorized
Content-Type: text/plain; charset=utf-8
X-Content-Type-Options: nosniff
Date: Sun, 18 Jul 2021 04:59:51 GMT
Content-Length: 39

Required authorization token not found
==================TOKEN 有り
curl -is localhost:8080/private-ping -H 'Authorization: Bearer ***************'
HTTP/1.1 200 OK
Date: Sun, 18 Jul 2021 04:59:51 GMT
Content-Length: 27
Content-Type: text/plain; charset=utf-8

{"message":"private pong"}
```
