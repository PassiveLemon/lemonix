local user = require("config.user")

local widgets = { }

-- Dynamically import widgets based on user config
for k, v in pairs(user.bar) do
  if v then
    widgets[k] = require("ui.bar.widgets." .. k)
  else
    widgets[k] = { }
  end
end

return widgets

