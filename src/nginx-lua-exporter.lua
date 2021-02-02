-- NGINX & OpenResty prometheus exporter
-- Github mohsenmottaghi/nginx-lua-exporter

local prometheus = {}

local exporters = require("lib.exporters")

-- Main functions
function prometheus.metrics()
  ngx.header.content_type = "text/plain"

  exporters.info()
  exporters.connection()
  exporters.requests()
  exporters.requestsHistogram()
  exporters.bandwith()
end

return prometheus
