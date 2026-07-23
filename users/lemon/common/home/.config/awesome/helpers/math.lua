local h = { }

function h.round(number, place)
  local decimal = (10 ^ place)
  return (math.floor((number * decimal) + (0.5 / decimal)) / decimal)
end

function h.clamp(number, bottom, top)
  -- Return the clamped value and a boolean for whether it was clamped or not
  if number > top then
    return top, true
  elseif number < bottom then
    return bottom, true
  end
  return number, false
end

-- Scale a number from one to another, so a 50 in a 0-100 scale becomes 32767.5 in a 0-65535 scale. Plugging in that same new value should return the initial value
function h.scale(number, ibottom, itop, obottom, otop)
  local _, i_clamped = h.clamp(number, ibottom, itop)
  -- Don't divide by zero
  if ibottom == 0 then
    ibottom = 1
  end
  if obottom == 0 then
    obottom = 1
  end
  -- Determine which way to scale depending on which range the number is part of
  if not i_clamped then
    -- New scale in a 0-1 unit scale
    local scale = number / itop
    -- Multiply onto target scale
    return (scale * otop)
  else
    local scale = number / otop
    return (scale * itop)
  end
end

return h

