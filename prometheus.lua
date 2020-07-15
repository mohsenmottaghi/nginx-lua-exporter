-- Openresty prometheus exporter
-- Github mohsenmottaghi/openresty-exporter

local banner = "MOHSEN MOTTAGHI | 2020 July"
local initialized = {}
local totalRequests = {}
local requestDetails = {}
local requestLatency = {}
local requestBuckets = {}
local connectionSummary = {{"reading", 0}, {"waiting", 0 }, {"writing", 0}}
local defaultBuckets = {0.005, 0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.2, 0.3,
                        0.4, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 10}
local testvar = ""

-- Operation functions
-- Get table len
function tableLen(tab)
  local count = 0
  for _ in pairs(tab) do count = count + 1 end
  return count
end

-- Find array in table with one index search
function tableSearchStatus1(tableName, positonIndex0, positionValue0)
  for i, value in ipairs(tableName) do
    if value[positonIndex0] == positionValue0 then
      return i
    end
  end
end

-- Find array in table with two index search
function tableSearchStatus2(tableName, positonIndex0, positionValue0, positonIndex1, positionValue1)
  for i, value in ipairs(tableName) do
    if value[positonIndex0] == positionValue0 then
      if value[positonIndex1] == positionValue1 then
        return i
      end
    end
  end
end

-- Initalize buckets for servername
function bucketInitialization(serverName)
  local preTableSize = tableLen(requestBuckets)
  for timeBucket = 1, tableLen(defaultBuckets) do
    requestBuckets[ preTableSize + timeBucket] = {serverName, defaultBuckets[timeBucket], 0}
  end
end

-- Metrics exporters
-- Total request base on status code exporter
function exportRequestDetails( )
  ngx.print("# HELP nginx_http_requests_total Number of HTTP requests", "\n",
            "# TYPE nginx_http_requests_total counter", "\n")
  for ind, result in ipairs(requestDetails) do
    if type(result) == "table" then
      ngx.print("nginx_http_requests_total{host=\"", result[1], "\",status=\"", result[2], "\"} ", result[3], "\n")
    end
  end
end

function exportConnectionSummary()
  ngx.print("# HELP nginx_http_connections Number of HTTP connections", "\n",
            "# TYPE nginx_http_connections gauge", "\n")
  for ind, result in ipairs(connectionSummary) do
    ngx.print("nginx_http_connections{state=\"", result[1], "\"} ", result[2], "\n")
  end
end

-- Histogram nginx_http_request_duration_seconds
function exportHistogramRequestDuration()
  ngx.print("# HELP nginx_http_request_duration_seconds HTTP request latency", "\n",
            "# TYPE nginx_http_request_duration_seconds histogram", "\n")
  for ind, result in ipairs(requestBuckets) do
    ngx.print("nginx_http_request_duration_seconds_bucket{host=\"", result[1], "\",le=\"", string.format("%.3f",result[2]), "\"} ", result[3], "\n")
  end

  for ind, result in ipairs(totalRequests) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_bucket{host=\"", result[1], "\",le=\"+Inf\"} ", result[2], "\n")
    end
  end

  for ind, result in ipairs(requestLatency) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_sum{host=\"", result[1],"\"} ", result[2], "\n")
    end
  end

  for ind, result in ipairs(totalRequests) do
    if type(result) == "table" then
      ngx.print("nginx_http_request_duration_seconds_count{host=\"", result[1],"\"} ", result[2], "\n")
    end
  end
end

-- Compute functions
-- Calculate total requests
function calTotalRequest(serverName)
  searchResult = tableSearchStatus1(totalRequests, 1, serverName)
  if searchResult == nil then
    totalRequests[tableLen(totalRequests) + 1] = {serverName, 1}
  else
    totalRequests[searchResult] = {serverName, totalRequests[searchResult][2] + 1 }
  end
end

-- Calculate total request base on status codes
function calRequestDetails(serverName, statusCode)
  searchResult = tableSearchStatus2(requestDetails, 1, serverName, 2, statusCode)
  if searchResult == nil then
    requestDetails[tableLen(requestDetails) + 1] = {serverName, statusCode, 1}
  else
    requestDetails[searchResult] = {serverName, statusCode, requestDetails[searchResult][3] + 1 }
  end
end

-- Calculate total request time
function calRequestLatency(serverName, requestTime)
  searchResult = tableSearchStatus1(requestLatency, 1, serverName)
  if searchResult == nil then
    requestLatency[tableLen(requestLatency) + 1] = {serverName, tonumber(requestTime)}
  else
    requestLatency[searchResult] = {serverName, requestLatency[searchResult][2] + tonumber(requestTime) }
  end
end

-- Calculate request time base on buckets
function calRequestBucket(serverName, requestTime)
  if tableSearchStatus1(initialized, 1, serverName) == nil then
    bucketInitialization(serverName)
    initialized[tableLen(initialized) + 1] = {serverName, true}
  end

  requestTime = tonumber(requestTime)
  for bucket = 1, tableLen(defaultBuckets)  do
    if defaultBuckets[bucket] >= requestTime then
      local searchResult = tableSearchStatus2(requestBuckets, 1, serverName, 2, defaultBuckets[bucket])
      requestBuckets[searchResult] = {serverName, defaultBuckets[bucket], requestBuckets[searchResult][3] + 1}
      -- break
    end
  end
end

-- Calculate connection status
function calConnectionSummary(reading,waiting,writing)
  connectionSummary[1] = {"reading" , reading}
  connectionSummary[2] = {"waiting" , waiting}
  connectionSummary[3] = {"writing" , writing}
end

-- Collectors
-- Request collector
function requestCollector(serverName, statusCode)
  calTotalRequest(serverName)
  calRequestDetails(serverName, statusCode)
end

-- Latency collector
function latencyCollector(serverName, requestTime)
  calRequestLatency(serverName, requestTime)
  calRequestBucket(serverName, requestTime)
end

-- Connection collector
function connectionCollector(reading,waiting,writing)
  calConnectionSummary(reading,waiting,writing)
end

-- Main functions
function PrometheusMetrics()
  ngx.header.content_type = "text/plain"
  ngx.print("# ", banner, "\n")
  exportConnectionSummary()
  exportRequestDetails()
  exportHistogramRequestDuration()
  -- ngx.print("\n")
end

return Prometheus
