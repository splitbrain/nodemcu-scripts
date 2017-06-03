--
-- Plant watering mechanism on the balcony
--
-- Controls the pump and reads the water level sensor
--
local module = {}

local PIN_LEVEL = 1 -- GPIO5


-- handle the low water level sensor
--
-- Sends water level info to the MQTT broker
--
-- @param {bool} level 1 for high water, 0 for low
-- @param {int} current timestamp
--
local function on_level_change(level, time)
  print("Low water sensor: " .. level)
  G.mqtt.publish("sensor/waterlevel", level)

  -- low water - disable the pump
  if(level == 0) then
    module.stop_pump()
  end

  -- listen to inverted state now
  gpio.trig(PIN_LEVEL, level == gpio.HIGH  and "down" or "up")
end

-- check the current water level
--
-- @returns {int} 1 for high water, 0 for low
--
local function current_level_ok()
  return gpio.read(PIN_LEVEL)
end

-- start the pump
--
-- checks the current water level and does nothing if it's too low
--
function module.start_pump()
  print "pump requested"
  if(current_level_ok()) then
    print "PUMP STARTED"
    G.mqtt.publish("sensor/pump", "1")
  end
end

-- stop the pump
function module.stop_pump()
  print "PUMP STOPPED"
  G.mqtt.publish("sensor/pump", "0")
end

-- configure everything
local function setup()
  -- start wifi and mqtt
  G.wifi.waitThen(G.mqtt.start)

  -- water level monitoring by interrupt
  gpio.mode(PIN_LEVEL, gpio.INT, gpio.PULLUP)
  gpio.trig(PIN_LEVEL, "down", on_level_change);

  -- register for pump commands
  G.mqtt.subscribe("switch/pump", function(data)
    if(data == "1") then
      module.start_pump()
    else
      module.stop_pump()
    end
  end)
end

-- run the application
function module.start()
  setup()
end

return module
