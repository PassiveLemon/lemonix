-- This is not actual code, it just gives an overview of how thing should work
-- Default variables
set = yes
enable = no
slidervalue = yes

positionupdater(value_state)
  get current position and song length
  if set = yes then
    set new current position with value_state
    set position of song
  end
  if enable = yes then
    slidervalue = no
    enable = no
    set slider.value = current position
  end
end

positionupdaterautomatic()
  set = no
  enable = yes
  call positionupdater()
end

slider property::value function()
  if slidervalue = yes then
    slider.value = value_state
    positionupdater(value_state)
  end
  slidervalue = yes
  set set = yes
  set enable = no
end

-- Workflows detailing the process of the 2 different calls. These are examples, not actual code
-- Using the slider
set = yes
enable = no
slidervalue = yes
slidervalue = yes so (
  I set slider
  slider value is updated to value_state
  calls postionupdater( with value state) (
    gets current position and song length
    set = yes so (
      current position is replaced with value state
      song position is set
    )
    enable != yes so (
      skip
    )
  )
  slidervalue = yes
  set set = yes
  set enable = no
  end
)

-- Updater function calling
set = yes
enable = no
slidervalue = yes
positionupdaterautomatic() (
  set set = no
  set enable = yes
  positionupdater() (
    gets current position and song length
    set != yes so (
      skip
    )
    enable = yes so (
      set slidervalue = no
      set slider.value = current position
      slider tries updating (
        slidervalue != yes so (
          skip
        )
        slidervalue = yes
        set set = yes
        set enable = no
        end
      )
    )
  )
)