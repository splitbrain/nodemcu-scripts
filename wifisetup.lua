--
-- Configures the WiFi
--
local module = {}

local callback = function() end -- the function run once the WiFi is up

-- Wait for the WiFi
--
-- called from an interval timer. Unsets the timer once an IP
-- was aquired. Then calls the configured callback
--
local function checkWiFi()
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
  else
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is " .. wifi.sta.getip())
    print("====================================")
    callback()
  end
end

-- Connect to WiFi and wait til an IP is ready
--
-- @param cb The function to call when IP is established
--
function module.waitThen(cb)
  callback = cb

  wifi.setmode(wifi.STATION)
  wifi.sta.sethostname(G.config.SELF)
  wifi.sta.config(G.config.WIFI)
  tmr.alarm(1, 2500, tmr.ALARM_AUTO, checkWiFi)
end

return module
