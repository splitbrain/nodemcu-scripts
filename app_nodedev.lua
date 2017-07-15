--
-- Just trying things
--
--
local module = {}

-- configure everything
local function setup()
  -- publish current level after startup
  G.mqtt.waitThen(function()

    print "all started"

  end)

  -- start wifi and mqtt
  G.wifi.waitThen(G.mqtt.start)

end

-- run the application
function module.start()
  setup()
end

return module
