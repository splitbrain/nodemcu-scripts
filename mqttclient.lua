--
-- Manage and maintain a permanent connection to a MQTT broker
--
-- A connection is retried when it gets interrupted. Previous subscriptions
-- will be reregistered. Each subscription can have it's own callback
--
local module = {}

local m = nil -- the MQTT client
local subscriptions = {}
local connected = false

local callback = function() end -- function to run after connect

-- handle new connection
local function on_connect(con)
  connected = true

  -- (re)subscribe to to all topics
  for topic, cb in pairs(subscriptions) do
     m:subscribe(topic, 2)
  end

  -- send Birth
  m:publish(G.config.MQTT.endpoint .. 'status', 'online', 1, 1)
  -- set LWT
  m:lwt(G.config.MQTT.endpoint .. 'status', 'offline', 1, 1)

  -- custom handler
  callback()

  print "MQTT connected"
end

-- handle disconnects
local function on_offline(client)
  connected = false

  -- try to reconnect in 10 seconds
  tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, module.start)

  print "MQTT disconnected"
end

-- handle errors
local function on_error(client, reason)
  print("Error on MQTT connection. Reason " .. reason)
  on_offline(client)
end

-- handle messages
local function on_message(con, topic, data)
  if data ~= nil then
    print("MQTT message received: " .. topic .. ": " .. data)
    if subscriptions[topic] ~= nil then
      -- call callback with message
      subscriptions[topic](data)
    end
  end
end

-- send some data to the broker
--
-- @param string topic The (sub topic) to send the data to
-- @param mixed payload The actual payload to send
-- @param int qos optional quality of service
-- @param int retain can optionally be set to 1 to let the broker keep the value
--
function module.publish(topic, payload, qos, retain)
  qos = qos or 0
  retain = retain or 0

  if(connected) then
    m:publish(G.config.MQTT.endpoint .. topic, payload, qos, retain)
    print("MQTT", topic, payload)
  else
    print("currently not connected to MQTT broker, cannot publish to " .. topic)
  end
end

-- subscribe to topic
--
-- The given callback will be called when a message is received for
-- the topic. The message will be provided as the first parameter
--
-- @param {string} topic The subtopic to subscribe to
-- @param {function} callback Will be called for messages
--
function module.subscribe(topic, callback)
  subscriptions[G.config.MQTT.endpoint .. topic] = callback

  if(connected) then
    m:subscribe(G.config.MQTT.endpoint .. topic, 0)
  end
end

-- run the given function on connect
function module.waitThen(cb)
  callback = cb
end

-- start MQTT connection
--
function module.start()
    -- create client
    m = mqtt.Client(
        G.config.SELF,
        25, -- keepalive
        G.config.MQTT.user,
        G.config.MQTT.pass,
        1 -- clean session
    )

    -- Connect to broker
    m:connect(
        G.config.MQTT.host,
        G.config.MQTT.port,
        0, -- non-secure
        0, -- autoreconnect NOT RECOMMENDED
        on_connect,
        on_error
    )

    -- register handlers
    m:on("message", on_message);
    m:on("offline", on_offline);
end


return module

