
local exporter = {}

local key = require("var.keys")
local config = require("config.config")
local operation = require("helper.operations")

local labels = operation.labelGenerator(config.labels)

function exporter.info()

  if config.showBanner == nil then config.showBanner = false end
  if config.bannerMessage == nil then config.bannerMessage = "Banner message is empty!" end

  if config.showBanner == true then
    ngx.print("# ", config.bannerMessage, "\n")
  end
end

function exporter.connection()
    ngx.print("# HELP nginx_http_connections Number of HTTP connections", "\n",
              "# TYPE nginx_http_connections gauge", "\n")
    for _, result in ipairs(key["connection"]) do
      ngx.print("nginx_http_connections{", labels ,"state=\"", result[1], "\"} ", result[2], "\n")
    end
end

-- Total request base on status code exporter
function exporter.requests()
    ngx.print("# HELP nginx_http_requests_total Number of HTTP requests", "\n",
              "# TYPE nginx_http_requests_total counter", "\n")
    for _, result in ipairs(key["requestsDetail"]) do
      if type(result) == "table" then
        ngx.print("nginx_http_requests_total{", labels ,
          "host=\"", result[1], "\",remote_addr=\"", result[2], "\",status=\"", result[3], "\"} ", result[4], "\n")
      end
    end

    -- Protocol
    if config.metricProtocol == nil then config.metricProtocol = false end

    if config.metricProtocol == true then
      ngx.print("# HELP nginx_http_requests_protocol_total Number of HTTP requests", "\n",
                "# TYPE nginx_http_requests_protocol_total counter", "\n")
      for _, result in ipairs(key["requestsProtocol"]) do
        if type(result) == "table" then
          ngx.print("nginx_http_requests_protocol_total{", labels ,"host=\"", result[1],
                      "\",protocol=\"", result[2], "\"} ", result[3], "\n")
        end
      end
    end

    -- Method
    if config.metricMethod == nil then config.metricMethod = false end

    if config.metricMethod == true then
      ngx.print("# HELP nginx_http_requests_method_total Number of HTTP requests", "\n",
                "# TYPE nginx_http_requests_method_total counter", "\n")
      for _, result in ipairs(key["requestsMethod"]) do
        if type(result) == "table" then
          ngx.print("nginx_http_requests_method_total{", labels ,"host=\"", result[1],
                      "\",method=\"", result[2], "\"} ", result[3], "\n")
        end
      end
    end

end

-- Histogram nginx_http_request_duration_seconds
function exporter.requestsHistogram()

  ngx.print("# HELP nginx_http_request_duration_seconds HTTP request latency", "\n",
            "# TYPE nginx_http_request_duration_seconds histogram", "\n")
  for _, result in ipairs(key["requestsBucket"]) do
    ngx.print(
      "nginx_http_request_duration_seconds_bucket{", labels ,"host=\"", result[1], "\",le=\"",
      string.format("%.3f",result[2]), "\"} ", result[3], "\n"
    )

    if result[2] == key["defaultBuckets"][#key["defaultBuckets"]] then
      local searchResult = operation.tableSearchStatus1(key["requestsTotal"], 1, result[1])
      ngx.print("nginx_http_request_duration_seconds_bucket{", labels ,"host=\"", result[1],
                  "\",le=\"+Inf\"} ", key["requestsTotal"][searchResult][2], "\n")
    end

  end

  for _, result in ipairs(key["requestsLatency"]) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_sum{", labels ,"host=\"", result[1],"\"} ", result[2], "\n")
    end
  end

  for _, result in ipairs(key["requestsTotal"]) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_count{", labels ,"host=\"", result[1],"\"} ", result[2], "\n")
    end
  end
end

-- Bandwith
function exporter.bandwith()
  if config.metricBandwith == nil then config.metricBandwith = false end

  if config.metricBandwith == true then
    ngx.print("# HELP nginx_http_bytes_received_total Number of HTTP bytes_received", "\n",
              "# TYPE nginx_http_bytes_received_total counter", "\n")
    for _, result in ipairs(key["bytesReceived"]) do
      if type(result) == "table" then
        ngx.print("nginx_http_bytes_received_total{", labels ,"host=\"", result[1], "\"} ", result[2], "\n")
      end
    end

    ngx.print("# HELP nginx_http_bytes_sent_total Number of HTTP bytes_sent", "\n",
              "# TYPE nginx_http_bytes_sent_total counter", "\n")
    for _, result in ipairs(key["bytesSent"]) do
      if type(result) == "table" then
        ngx.print("nginx_http_bytes_sent_total{", labels ,"host=\"", result[1], "\"} ", result[2], "\n")
      end
    end
  end

end


function exporter.test()
  ngx.print("\n----------------------------------------------------\n")
  ngx.print(key["requestsDetail"])
  ngx.print("\n----------------------------------------------------\n")
end

return exporter
