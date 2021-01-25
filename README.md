# NGINX Lua exporter
![Check Lua Lint](https://github.com/mohsenmottaghi/nginx-lua-exporter/workflows/Check%20Lua%20Lint/badge.svg)
![Build Lua Rocks Package](https://github.com/mohsenmottaghi/nginx-lua-exporter/workflows/Build%20Lua%20Rocks%20Package/badge.svg)


## How to install
To install this module you have to option:
1. Use Luarocks 
    ```bash
    luarocks install nginx-lua-exporter
    ```
2. Clone this repo or download files ( Note: We recommend using tags and releases)

## How to setup

To collect data from Openresty, edit `nginx.conf` :

```
http {
...

    lua_shared_dict prometheus_memory 10M;
    lua_package_path "/< PATH TO FILES >/?.lua;;";


    log_by_lua_block {
        local collector = require("lib.collectors")
        collector.requests(ngx.var.server_name, ngx.var.status, ngx.var.server_protocol, ngx.var.request_method)
        collector.latency(ngx.var.server_name, ngx.var.request_time)
    }
...
}
```

To expose metrics on `/< PATH TO FILES >` edit server context like this:

```
server {
    ...

    location /<PATH> {
        content_by_lua_block {
            local prometheus = require("nginx-lua-exporter")
            local collector = require("lib.collectors")

            collector.connection(
                                ngx.var.connections_reading,
                                ngx.var.connections_waiting,
                                ngx.var.connections_writing
                              )

            prometheus.metrics();
        }
    }
    ...
}
```

## Test and Develop

Run a test instance with `Podman` or `Docker`:
```bash
podman run -it --rm --name nginx-lua-expoerter-test -v $PWD/example/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf  -v $PWD/example/server.conf:/etc/nginx/conf.d/default.conf -v $PWD/src:/opt/prometheus -p 8080:80 docker.io/openresty/openresty
```

Run lua lint test:
```bash
podman run --rm -it -v $PWD:/opt docker.io/birdy/docker-luacheck /opt --globals ngx
```