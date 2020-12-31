-- NGINX & OpenResty prometheus exporter
-- Github mohsenmottaghi/openresty-exporter

local banner = "NGINX Lua exporter | MOHSEN MOTTAGHI | 2021 Jun"

local exporters = require("prometheus_exporters")

-- Main functions
function PrometheusMetrics()
  ngx.header.content_type = "text/plain"
  ngx.print("# ", banner, "\n")

  exporters.connection()
  exporters.requests()
  exporters.requestsHistogram()

end

return true
