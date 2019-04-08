-- Helper methods

local module = {}

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
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. "}\n"
    else
        return tostring(o)
    end
end


return module
