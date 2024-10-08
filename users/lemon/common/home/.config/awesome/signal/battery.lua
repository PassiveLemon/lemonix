local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

-- signal::battery::subscribe (emit)
-- (action) (name) (percent) (command)
-- action: bool -> set true to subscribe the item, false to unsubscribe
-- name: str -> the visual name of the item
-- percent: int >= 0 -> the percent at which to trigger a warning
-- command: str -> the command which should return an integer of the current item battery
-- example -> awesome.emit_signal("signal::battery::subscribe", true, "Headset", 20, "headsetcontrol -c -b")

-- signal::battery::status::(name) (connect)
-- (percent)

-- signal::battery::status (connect)
-- (name) (percent)

-- subscribers = {
--   name = { (name) (notified) (percent) (command) }
-- }

local subscribers = { }

local function subscribe(action, name, percent, command)
  local percent = tonumber(percent)

  if action then
    subscribers[name] = {
      name = name,
      notify = true,
      percent = percent,
      command = command
    }
  else
    subscribers[name] = nil
  end
end

local function check(subscriber)
  awful.spawn.easy_async_with_shell(subscriber.command, function(stdout)
    local stdout = tonumber(stdout)

    awesome.emit_signal(("signal::battery::status::" .. subscriber.name), stdout)
    awesome.emit_signal("signal::battery::status", subscriber.name, stdout)
    
    if subscriber.notify and stdout >= 0 and stdout <= subscriber.percent then
      naughty.notification({
        title = subscriber.name .. " battery low (" .. tostring(subscriber.percent) .. "%)",
        timeout = 7
      })
      subscriber.notify = false
    elseif stdout > subscriber.percent then
      subscriber.notify = true
    end
  end)
end

local function main()
  for _, v in pairs(subscribers) do
    check(v)
  end
end

local main_timer = gears.timer({
  timeout = 5,
  autostart = true,
  callback = function()
    main()
  end,
})

awesome.connect_signal("signal::battery::subscribe", function(action, name, percent, command)
  subscribe(action, name, percent, command)
end)

