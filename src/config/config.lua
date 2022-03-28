
local config = {}

-- If do not specify a value the default value is false!

-- Show Banner
config.showBanner = false
config.bannerMessage = "NGINX Lua exporter | MOHSEN MOTTAGHI | 2022"

-- metric config
-- Show client connection protocol (HTTP version)
config.metricProtocol = false
-- Show client connection method (GET, POST, etc.)
config.metricMethod = false

-- This is a beta feature
-- Show client connection bandwidth
config.metricBandwith = false

-- This is a beta feature
-- Show client remote address
-- We will continue to add support from diffrent header like X-Forwarded-For, X-Real-IP, etc.
config.logRemoteAddress = false

-- Custom key value
-- ٍExample: config.labels = { {"Key_1", "Value_1"}, {"Key_2", "Value_2"} }
config.labels = {}

return config