IN_PINS = { 5, 6, 7, 8 }
SUBMIT_PIN = 2
BUZZER_PIN = 3

COLORCODES = {
    blue = { 0, 0, 128 },
    green = { 0, 128, 0 },
    orange = { 128, 64, 0 },
    purple = { 128, 0, 128 },
    red = { 128, 0, 0 },
    yellow = { 128, 128, 0 }
}
ROWS = 8
COLORS = {}
STEP = 0
MATRIX = {}
CODE = {}
INPUT = {}
BUFFER = {}

local function dump(o)
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

function beep(pin, freq, duration)
    print("Frequency:" .. freq)
    pwm.setup(pin, freq, 512)
    pwm.start(pin)
    -- delay in uSeconds
    tmr.delay(duration * 1000)
    pwm.stop(pin)
    --20ms pause
    tmr.wdclr()
    tmr.delay(20000)
end

local function generateCode()
    local t = { unpack(COLORS) }

    local rand = node.random
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end

    return { t[1], t[2], t[3], t[4] }
end

local function validateInput(code, input)
    local exact = 0
    local close = 0

    for k, v in pairs(input) do
        if v == code[k] then
            exact = exact + 1
        else
            for x, y in pairs(code) do
                if y == v then
                    close = close + 1
                end
            end
        end
    end

    return exact, close
end

function updateRGB()
    local pos = 1

    for i = 1, #INPUT do
        BUFFER:set(pos, colorToRGB(INPUT[i]))
        pos = pos + 1
    end

    for i = 1, #MATRIX do
        for j = 1, #INPUT * 2 do
            BUFFER:set(pos, colorToRGB(MATRIX[i][j]))
            pos = pos + 1
        end
    end

    ws2812.write(BUFFER)
end

local function reset()
    for r = 1, ROWS do
        MATRIX[r] = { '', '', '', '', '', '', '', '' }
    end

    STEP = 1
    CODE = { '', '', '', '' }
    INPUT = { '', '', '', '' }

    updateRGB()
end

local function submit()
    local pos = 0

    beep(BUZZER_PIN, 250, 100)

    -- copy input to the matrix
    for k, v in pairs(INPUT) do
        pos = pos + 1
        MATRIX[STEP][pos] = v
    end

    -- show exact and close matches
    local exact, close = validateInput(CODE, INPUT)
    for i = 1, exact do
        pos = pos + 1
        MATRIX[STEP][pos] = 'exact'
    end
    for i = 1, close do
        pos = pos + 1
        MATRIX[STEP][pos] = 'close'
    end

    updateRGB()

    -- check if win
    if exact == 4 then
        print "WINNER WINNER WINNER"
        return
    end

    -- next step
    STEP = STEP + 1
    if STEP > #MATRIX then
        print "LOSER LOSER LOSER"
        reset()
    end
end

local function toggleInput(field)
    local found = 0

    for i = 1, #COLORS do
        if COLORS[i] == INPUT[field] then
            found = i
            break
        end
    end

    found = found + 1
    if found > #COLORS then
        found = 1
    end

    INPUT[field] = COLORS[found]
    updateRGB()

    beep(BUZZER_PIN, 880, 100)

    print(dump(INPUT))
end

local function setup(field)
    local last = 0

    -- set up input buttons
    for idx, pin in pairs(IN_PINS) do
        gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
        gpio.trig(
                pin,
                'up',
                function(level, pulse, cnt)
                    -- button debounce
                    if (pulse - last < 250 or level == 0) then
                        return
                    end
                    last = pulse

                    print("click " .. level .. " pulse  " .. pulse .. " cnt " .. cnt)
                    toggleInput(idx)
                end
        )
    end

    -- setup submit button
    gpio.mode(SUBMIT_PIN, gpio.INPUT, gpio.PULLUP)
    gpio.trig(
            SUBMIT_PIN,
            'up',
            function(level, pulse, cnt)
                -- button debounce
                if (pulse - last < 1000 or level == 0) then
                    return
                end
                last = pulse

                print("click " .. level .. " pulse  " .. pulse .. " cnt " .. cnt)
                submit()
            end
    )

    -- make color names available
    for k, v in pairs(COLORCODES) do
        COLORS[#COLORS + 1] = k
    end

    -- set up RGB buffer
    local leds = (#IN_PINS * 2 * ROWS) + #IN_PINS
    print("initializing " .. leds .. " LEDs")
    ws2812.init()
    BUFFER = ws2812.newBuffer(leds, 3)
    BUFFER:fill(colorToRGB(''))
    ws2812.write(BUFFER)
end

function colorToRGB(color)
    if COLORCODES[color] then
        return unpack(COLORCODES[color])
    elseif color == "exact" then
        return 0, 153, 0
    elseif color == "close" then
        return 204, 102, 0
    else
        return 64, 64, 64
    end

end

setup()
reset()
print(dump(MATRIX))

CODE = generateCode()
print(dump(CODE))

INPUT = generateCode()
toggleInput(1)
toggleInput(2)
toggleInput(3)
toggleInput(4)
submit()

print(dump(MATRIX))

