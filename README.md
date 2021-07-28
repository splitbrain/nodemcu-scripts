# NodeMCU Scripts
> Scripts to power my nodemcu boards

This is a simple framework to run on a NodeMCU controller. It takes care of
configuring the WiFi and provides an easy way to subscribe and publish MQTT
messages (handling all the possible errors by reconnecting).

I will probably run multiple NodeMCUs in the future. To make it easier, they
will all receive the same lua files, but each one will run a specific `app_*.lua`

Which NodeMCU is responsible for what is configured in the `nodenames` table of
`config.lua` - the `node.chipid()` is used to figure out where we run.

The `config.lua` also contains some basic setup for the WiFi and the MQTT broker.

Passwords have to be placed in a `secrets.lua`, see the dist file for the format.

The wifi setup has a `g.wifi.waitThen()` method accepting a callback that will
be run only after an IP address has been assigned. You will probably want to wait
fo that befor starting the MQTT client.

See `app_balcony.lua` for an example application. It allows the control of a water
pump via MQTT. However the pump will not run when the water level is too low.
