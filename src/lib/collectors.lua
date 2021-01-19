local collector = {}

local calculator = require("lib.calculators")
local config = require("config.config")

-- Connection collector
function collector.connection(reading,waiting,writing)
    calculator.connection(reading,waiting,writing)
end

-- Request collector
function collector.requests(serverName, statusCode, serverProtocol, serverMethod)
    calculator.requestsTotal(serverName)
    calculator.requestsDetail(serverName, statusCode)

    if config.metricProtocol == true then
        calculator.requestsProtocol(serverName, serverProtocol)
    end

    if config.metricMethod == true then
        calculator.requestsMethod(serverName, serverMethod)
    end

end

-- Latency collector
function collector.latency(serverName, requestTime)
    calculator.latency(serverName, requestTime)
    calculator.bucket(serverName, requestTime)
end

return collector
