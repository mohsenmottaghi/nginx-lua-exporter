# NGINX Lua exporter
![Check Lua Lint](https://github.com/mohsenmottaghi/nginx-lua-exporter/workflows/Check%20Lua%20Lint/badge.svg)

# How to setup

To collect data from Openresty, edit `nginx.conf` :

```
http {
...

    lua_shared_dict prometheus_metrics 10M;
    lua_package_path "/opt/prometheus/?.lua;;";

    log_by_lua_block {
        local collector = require("prometheus_collectors")
        collector.requests(ngx.var.server_name, ngx.var.status)
        collector.latency(ngx.var.server_name, ngx.var.request_time)
    }
...
}
```

To expose metrics on `/<PATH>` edit server context like this:

```
server {
    ...

    location /<PATH> {
        content_by_lua_block {
            local prometheus = require("prometheus")
            local collector = require("prometheus_collectors")

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