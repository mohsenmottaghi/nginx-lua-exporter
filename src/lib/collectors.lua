local collector = {}

local calculator = require("lib.calculators")
local config = require("config.config")

-- Connection collector
function collector.connection(reading,waiting,writing)
    calculator.connection(reading,waiting,writing)
end

-- Request collector
function collector.requests(serverName, statusCode, serverProtocol, serverMethod, remoteAddress)

    if config.logRemoteAddress == false then
        remoteAddress = "-"
    end

    calculator.requestsTotal(serverName, remoteAddress)
    calculator.requestsDetail(serverName, remoteAddress, statusCode)

    if config.metricProtocol == nil then config.metricProtocol = false end
    if config.metricProtocol == true then
        calculator.requestsProtocol(serverName, serverProtocol)
    end

    if config.metricMethod == nil then config.metricMethod = false end
    if config.metricMethod == true then
        calculator.requestsMethod(serverName, serverMethod)
    end

end

-- Latency collector
function collector.latency(serverName, requestTime)
    calculator.latency(serverName, requestTime)
    calculator.bucket(serverName, requestTime)
end

-- Network collector
function collector.bandwith(serverName, bytesReceived, bytesSent)
    if config.metricBandwith == nil then config.metricBandwith = false end

    if config.metricBandwith == true then
        calculator.bandwith(serverName, bytesReceived, bytesSent)
    end

end

return collector
