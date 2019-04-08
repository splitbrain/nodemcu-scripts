-- Helper methods

local module = {}

-- Debounce a function
--
-- @link https://gist.github.com/marcelstoer/59563e791effa4acb65f
-- @param {function} func The function to execute unless it's still debouncing
-- @param [{int}] delay How long to supress additional calls
function module.debounce (func, delay)
    local last = 0
    delay = delay or 250
    delay = delay * 1000 -- tmr.now() has μs resolution

    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
        if delta < delay then return end;

        last = now
        return func(...)
    end
end

-- Helper to dump complex objects into a string
--
-- @param {object} o
-- @return {string}
function module.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. module.dump(v) .. ','
        end
        return s .. "}\n"
    else
        return tostring(o)
    end
end


return module
