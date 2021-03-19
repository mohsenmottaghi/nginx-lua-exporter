
local config = {}

-- If do not specify a value the default value is false!

-- Show Banner
config.showBanner = false
config.bannerMessage = "NGINX Lua exporter | MOHSEN MOTTAGHI | 2021"

-- metric config
config.metricProtocol = false
config.metricMethod = false

-- This is a beta feature
config.metricBandwith = false

-- Custom key value
-- ٍExample: config.labels = { {"Key_1", "Value_1"}, {"Key_2", "Value_2"} }
config.labels = {}

return config