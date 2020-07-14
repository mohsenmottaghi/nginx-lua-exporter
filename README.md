# openresty-exporter
OpenResty Prometheus exporter

# How to setup

To collect data from Openresty, edit `nginx.conf` :

```
http {
...

    lua_shared_dict prometheus_metrics 10M;
    lua_package_path "/opt/prometheus.lua;;";

    log_by_lua_block {
        requestCollector(ngx.var.server_name, ngx.var.status)
        latencyCollector(ngx.var.server_name, ngx.var.request_time)
    }
...
}
```

To expose metrics on `/<PATH>` edit server context like this:

```
server {
    ...

    location = /metrics {
        content_by_lua_block {
            connectionCollector(
                                ngx.var.connections_reading,
                                ngx.var.connections_waiting,
                                ngx.var.connections_writing
                              )
            PrometheusMetrics()
        }
    }

    ...
}
```