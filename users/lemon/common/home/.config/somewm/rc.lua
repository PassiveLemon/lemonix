local lgi = require("lgi")
local Gio = lgi.Gio
local GioUnix = lgi.GioUnix

if not Gio.UnixInputStream and GioUnix then
  Gio.UnixInputStream = GioUnix.InputStream
  Gio.UnixOutputStream = GioUnix.OutputStream
end
if not Gio.DesktopAppInfo and GioUnix then
  Gio.DesktopAppInfo = GioUnix.DesktopAppInfo
end

require("config")
require("ui")

