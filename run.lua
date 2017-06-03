--
-- Register all our modules in a global table
-- then run the app for this NodeMCU
--

G = {}
G.secrets = require("secrets")
G.config = require("config")
G.wifi = require("wifisetup")
G.mqtt = require("mqttclient")
G.app = require("app_" .. G.config.SELF)

G.app.start()
