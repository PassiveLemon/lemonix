local tym = require("tym")

-- set by table
tym.set_config({
  shell = os.getenv("HOME") .. "/.local/state/nix/profile/bin/hilbish",
  silent = true,
  padding_top = 8,
  padding_right = 8,
  padding_bottom = 8,
  padding_left = 8,
  cell_width = 80,
  cell_height = 100,
  scrollback_length = 2048,
  scrollback_on_output = true,
  cursor_shape = "block",
  font = "FiraCode Nerd Font Mono Ret 10",
})
