
local initialization = {}

local key = require("prometheus_keys")
local operation = require("prometheus_operations")

-- Initalize buckets for servername
function initialization.bucket(serverName)
  local preTableSize = operation.tableLen(key.requestsBucket)
  for timeBucket = 1, operation.tableLen(key.defaultBuckets) do
    key.requestsBucket[ preTableSize + timeBucket] = {serverName, key.defaultBuckets[timeBucket], 0}
  end
end

return initialization