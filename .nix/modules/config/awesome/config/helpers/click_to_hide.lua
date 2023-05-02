-- Credit to https://bitbucket.org/grumph/home_config/src/master/.config/awesome/helpers/click_to_hide.lua

local awful = require "awful"
local wibox = require "wibox"

local function click_to_hide(widget, hide_fct, only_outside)
	only_outside = only_outside or false

	hide_fct = hide_fct or function(object)
		if only_outside and object == widget then
			return
		end
	widget.visible = false
	end

	local click_bind = awful.button({ }, 1, hide_fct)

	local function manage_signals(w)
		if not w.visible then
			wibox.disconnect_signal("button::press", hide_fct)
			client.disconnect_signal("button::press", hide_fct)
			awful.mouse.remove_global_mousebinding(click_bind)
		else
			awful.mouse.append_global_mousebinding(click_bind)
			client.connect_signal("button::press", hide_fct)
			wibox.connect_signal("button::press", hide_fct)
		end
	end

	-- when the widget is visible, we hide it on button press
	widget:connect_signal('property::visible', manage_signals)

	function widget.disconnect_click_to_hide()
		widget:disconnect_signal('property::visible', manage_signals)
	end

end

local function click_to_hide_menu(menu, hide_fct, outside_only)
	hide_fct = hide_fct or function()
		menu:hide()
	end

	click_to_hide(menu.wibox, hide_fct, outside_only)
end

return {
	menu = click_to_hide_menu,
	popup = click_to_hide,
}
