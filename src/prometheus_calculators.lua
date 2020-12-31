local calculator = {}

local key = require("prometheus_keys")
local operation = require("prometheus_operations")
local initialization = require("prometheus_initialization")


-- Calculate connection status
function calculator.connection(reading,waiting,writing)
    key.connection[1] = {"reading" , reading}
    key.connection[2] = {"waiting" , waiting}
    key.connection[3] = {"writing" , writing}
end

-- Calculate total requests
function calculator.requestsTotal(serverName)
  local searchResult = operation.tableSearchStatus1(key.requestsTotal, 1, serverName)
  if searchResult == nil then
    key.requestsTotal[operation.tableLen(key.requestsTotal) + 1] = {serverName, 1}
  else
    key.requestsTotal[searchResult] = {serverName, key.requestsTotal[searchResult][2] + 1 }
  end
end

-- Calculate total request base on status codes
function calculator.requestsDetail(serverName, statusCode)
    local searchResult = operation.tableSearchStatus2(key.requestsDetail, 1, serverName, 2, statusCode)
    if searchResult == nil then
      key.requestsDetail[operation.tableLen(key.requestsDetail) + 1] = {serverName, statusCode, 1}
    else
      key.requestsDetail[searchResult] = {serverName, statusCode, key.requestsDetail[searchResult][3] + 1 }
    end
end

-- Calculate total request time
function calculator.latency(serverName, requestTime)
  local searchResult = operation.tableSearchStatus1(key.requestsLatency, 1, serverName)
  if searchResult == nil then
    key.requestsLatency[operation.tableLen(key.requestsLatency) + 1] = {serverName, tonumber(requestTime)}
  else
    key.requestsLatency[searchResult] = {serverName, key.requestsLatency[searchResult][2] + tonumber(requestTime) }
  end
end

-- Calculate request time base on buckets
function calculator.bucket(serverName, requestTime)
  if operation.tableSearchStatus1(key.initialized, 1, serverName) == nil then
    initialization.bucket(serverName)
    key.initialized[operation.tableLen(key.initialized) + 1] = {serverName, true}
  end

  requestTime = tonumber(requestTime)
  for bucket = 1, operation.tableLen(key.defaultBuckets)  do
    if key.defaultBuckets[bucket] >= requestTime then
      local searchResult = operation.tableSearchStatus2(key.requestsBucket, 1, serverName, 2, key.defaultBuckets[bucket])
      key.requestsBucket[searchResult] = {serverName, key.defaultBuckets[bucket], key.requestsBucket[searchResult][3] + 1}
      -- break
    end
  end
end

return calculator