local user = require("config.user")

local widgets = { }

-- Dynamically import widgets based on user config
for k, v in pairs(user.control) do
  if v then
    widgets[k] = require("ui.popup.widgets." .. k)
  else
    widgets[k] = { }
  end
end

return widgets

