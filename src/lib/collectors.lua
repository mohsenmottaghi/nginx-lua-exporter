local collector = {}

local calculator = require("lib.calculators")

-- Connection collector
function collector.connection(reading,waiting,writing)
    calculator.connection(reading,waiting,writing)
end

-- Request collector
function collector.requests(serverName, statusCode)
    calculator.requestsTotal(serverName)
    calculator.requestsDetail(serverName, statusCode)
end

-- Latency collector
function collector.latency(serverName, requestTime)
    calculator.latency(serverName, requestTime)
    calculator.bucket(serverName, requestTime)
end

return collector
