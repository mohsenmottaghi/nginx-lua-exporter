-- NGINX & OpenResty prometheus exporter
-- Github mohsenmottaghi/openresty-exporter

local banner = "NGINX Lua exporter | MOHSEN MOTTAGHI | 2021 Jun"

local prometheus = {}

local exporters = require("lib.exporters")

-- Main functions
function prometheus.metrics()
  ngx.header.content_type = "text/plain"
  ngx.print("# ", banner, "\n")

  exporters.connection()
  exporters.requests()
  exporters.requestsHistogram()
end

return prometheus
