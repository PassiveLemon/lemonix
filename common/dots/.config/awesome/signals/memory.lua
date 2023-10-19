local awful = require("awful")

--
-- Memory watches
--

-- Separate individual uses, maximums, caches, etc and parse them together

awful.widget.watch("echo", 2, function()
  awful.spawn.easy_async_with_shell([[sh -c "free -g | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$3); gsub(/Gi/,\"\",\$2); print \$3\"/\"\$2}'"]], function(use)
    local use = use:gsub("\n", "")
    awful.spawn.easy_async_with_shell([[sh -c "free -g | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$3); printf \"%.0f\", (\$3/\$2)*100}'"]], function(use_perc)
      local use_perc = use_perc:gsub("\n", "")
      awful.spawn.easy_async_with_shell([[sh -c "free -g | grep 'Mem:' | awk '{gsub(/Gi/,\"\",\$6); gsub(/Gi/,\"\",\$2); print \$6\"/\"\$2}'"]], function(cache)
        local cache = cache:gsub("\n", "")
        awful.spawn.easy_async_with_shell([[sh -c "free -g | awk '/Mem:/{gsub(/Gi/,\"\",\$2); gsub(/Gi/,\"\",\$6); printf \"%.0f\", (\$6/\$2)*100}'"]], function(cache_perc)
          local cache_perc = cache_perc:gsub("\n", "")
          awesome.emit_signal("signal::memory", use, use_perc, cache, cache_perc)
        end)
      end)
    end)
  end)
end)
