
local key = {}

key.initialized = {}
key.connection = {{"reading", 0}, {"waiting", 0 }, {"writing", 0}}
key.requestsTotal = {}
key.requestsDetail = {}
key.requestsLatency = {}
key.requestsBucket = {}
key.defaultBuckets = {0.005, 0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.2, 0.3,
                        0.4, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 10}

return key