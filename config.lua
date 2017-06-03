--
-- Basic configuration
--
-- This should be the same for all my apps. Secrets are stored in secrets.lua
--
local module = {}

-- identify NodeMCU by chipid
local nodenames = {}
nodenames[10702156] = "balcony"
module.SELF = nodenames[node.chipid()]
if module.SELF == nil then
  module.SELF = node.chipid()
  print("FAILED TO IDENTIFY NODEMCU CHIP")
end

-- configure wifi
module.WIFI = {}
module.WIFI.ssid = "W00t"
module.WIFI.pass = G.secrets.WIFIPASS

-- configure MQTT
module.MQTT = {}
module.MQTT.host = "192.168.1.8"
module.MQTT.port = 1883
module.MQTT.user = "home-assistant"
module.MQTT.pass = G.secrets.MQTTPASS
module.MQTT.endpoint = "/home-assistant/" .. module.SELF .. "/"

return module
