local calculator = {}

local key = require("var.keys")
local operation = require("helper.operations")
local initialization = require("lib.initialization")


-- Calculate connection status
function calculator.connection(reading,waiting,writing)
    key["connection"][1] = {"reading" , reading}
    key["connection"][2] = {"waiting" , waiting}
    key["connection"][3] = {"writing" , writing}
end

-- Calculate total requests
function calculator.requestsTotal(serverName)
  local searchResult = operation.tableSearchStatus1(key["requestsTotal"], 1, serverName)
  if searchResult == nil then
    key["requestsTotal"][operation.tableLen(key["requestsTotal"]) + 1] = {serverName, 1}
  else
    key["requestsTotal"][searchResult] = {serverName, key["requestsTotal"][searchResult][2] + 1 }
  end
end

-- Calculate total request base on status codes
function calculator.requestsDetail(serverName, statusCode)
    local searchResult = operation.tableSearchStatus2(key["requestsDetail"], 1, serverName, 2, statusCode)
    if searchResult == nil then
      key["requestsDetail"][operation.tableLen(key["requestsDetail"]) + 1] = {serverName, statusCode, 1}
    else
      key["requestsDetail"][searchResult] = {serverName, statusCode, key["requestsDetail"][searchResult][3] + 1 }
    end
end

-- Calculate request base on server protocol
function calculator.requestsProtocol(serverName, serverProtocol)
  local searchResult = operation.tableSearchStatus2(key["requestsProtocol"], 1, serverName, 2, serverProtocol)
  if searchResult == nil then
    key["requestsProtocol"][operation.tableLen(key["requestsProtocol"]) + 1] = {serverName, serverProtocol, 1}
  else
    key["requestsProtocol"][searchResult] = {serverName, serverProtocol, key["requestsProtocol"][searchResult][3] + 1 }
  end
end

-- Calculate request base on method
function calculator.requestsMethod(serverName, requestMethod)
  local searchResult = operation.tableSearchStatus2(key["requestsMethod"], 1, serverName, 2, requestMethod)
  if searchResult == nil then
    key["requestsMethod"][operation.tableLen(key["requestsMethod"]) + 1] = {serverName, requestMethod, 1}
  else
    key["requestsMethod"][searchResult] = {serverName, requestMethod, key["requestsMethod"][searchResult][3] + 1 }
  end
end

-- Calculate total request time
function calculator.latency(serverName, requestTime)
  local searchResult = operation.tableSearchStatus1(key["requestsLatency"], 1, serverName)
  if searchResult == nil then
    key["requestsLatency"][operation.tableLen(key["requestsLatency"]) + 1] = {serverName, tonumber(requestTime)}
  else
    key["requestsLatency"][searchResult] = {
      serverName, key["requestsLatency"][searchResult][2] + tonumber(requestTime)
    }
  end
end

-- Calculate request time base on buckets
function calculator.bucket(serverName, requestTime)
  if operation.tableSearchStatus1(key["initialized"], 1, serverName) == nil then
    initialization.bucket(serverName)
    key["initialized"][operation.tableLen(key["initialized"]) + 1] = {serverName, true}
  end

  requestTime = tonumber(requestTime)
  for bucket = 1, operation.tableLen(key["defaultBuckets"])  do
    if key["defaultBuckets"][bucket] >= requestTime then
      local searchResult = operation.tableSearchStatus2(
        key["requestsBucket"], 1, serverName, 2, key["defaultBuckets"][bucket]
      )
      key["requestsBucket"][searchResult] = {
        serverName, key["defaultBuckets"][bucket], key["requestsBucket"][searchResult][3] + 1
      }
      -- break
    end
  end
end

-- Calculate Bandwith
function calculator.bandwith(serverName, bytesReceived, bytesSent)

  if bytesReceived == nil then bytesReceived = 0 end
  if bytesSent == nil then bytesSent = 0 end

  local searchResultReceived = operation.tableSearchStatus1(key["bytesReceived"], 1, serverName)
  if searchResultReceived == nil then
    key["bytesReceived"][operation.tableLen(key["bytesReceived"]) + 1] = {serverName, bytesReceived}
  else
    key["bytesReceived"][searchResultReceived] = {
      serverName, key["bytesReceived"][searchResultReceived][2] + bytesReceived }
  end

  local searchResultSent = operation.tableSearchStatus1(key["bytesSent"], 1, serverName)
  if searchResultSent == nil then
    key["bytesSent"][operation.tableLen(key["bytesSent"]) + 1] = {serverName, bytesSent}
  else
    key["bytesSent"][searchResultSent] = {serverName, key["bytesSent"][searchResultSent][2] + bytesSent }
  end

end

return calculator