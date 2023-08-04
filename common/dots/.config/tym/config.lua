local tym = require("tym")

-- set by table
tym.set_config{
  shell = "/run/current-system/sw/bin/hilbish",
  silent = true,
  padding_horizontal = 8,
  padding_vertical = 8,
  cell_width = 80,
  cell_height = 100,
  scrollback_length = 1024,
  cursor_shape = "block",
  font = "FiraCode Nerd Font Mono SemBd 10",
}
