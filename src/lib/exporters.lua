
local exporter = {}

local key = require("var.keys")
local config = require("config.config")

function exporter.info()
  if config.showBanner == true then
    local banner = "NGINX Lua exporter | MOHSEN MOTTAGHI | 2021 "
    ngx.print("# ", banner, "\n")
  end
end

function exporter.connection()
    ngx.print("# HELP nginx_http_connections Number of HTTP connections", "\n",
              "# TYPE nginx_http_connections gauge", "\n")
    for _, result in ipairs(key["connection"]) do
      ngx.print("nginx_http_connections{state=\"", result[1], "\"} ", result[2], "\n")
    end
end

-- Total request base on status code exporter
function exporter.requests( )
    ngx.print("# HELP nginx_http_requests_total Number of HTTP requests", "\n",
              "# TYPE nginx_http_requests_total counter", "\n")
    for _, result in ipairs(key["requestsDetail"]) do
      if type(result) == "table" then
        ngx.print("nginx_http_requests_total{host=\"", result[1], "\",status=\"", result[2], "\"} ", result[3], "\n")
      end
    end
end

-- Histogram nginx_http_request_duration_seconds
function exporter.requestsHistogram()
  ngx.print("# HELP nginx_http_request_duration_seconds HTTP request latency", "\n",
            "# TYPE nginx_http_request_duration_seconds histogram", "\n")
  for _, result in ipairs(key["requestsBucket"]) do
    ngx.print(
      "nginx_http_request_duration_seconds_bucket{host=\"", result[1], "\",le=\"",
      string.format("%.3f",result[2]), "\"} ", result[3], "\n"
    )
  end

  for _, result in ipairs(key["requestsTotal"]) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_bucket{host=\"", result[1], "\",le=\"+Inf\"} ", result[2], "\n")
    end
  end

  for _, result in ipairs(key["requestsLatency"]) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_sum{host=\"", result[1],"\"} ", result[2], "\n")
    end
  end

  for _, result in ipairs(key["requestsTotal"]) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_count{host=\"", result[1],"\"} ", result[2], "\n")
    end
  end
end

return exporter
