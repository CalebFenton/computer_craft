DIRECTION_SHIELD = "bottom"
DIRECTION_MODEM = "front"

power_status = true

function setShield(status)
  if status == true then
    rs.setBundledOutput(DIRECTION_SHIELD, 0)
  else
    rs.setBundledOutput(DIRECTION_SHIELD, colors.white)
  end
end

function setPower(status)
  local modem = peripheral.wrap("front")
  if status == true then
    modem.transmit(7, 7, "enable")
  else
    modem.transmit(7, 7, "disable")
  end
end

function toggleShield()
  local active = rs.getBundledOutput(DIRECTION_SHIELD)
  local isUp = not colors.test(active, colors.white)
  setShield(not isUp)
end

function togglePower()
  power_status = not power_status
  setPower(power_status)
end

setShield(true)
setPower(true)

os.loadAPI("touchpoint")

local t = touchpoint.new("back")
t:add("Shield", nil, 2, 2, 14, 11, colors.lime, colors.red)
t:add("Power", nil, 16, 2, 28, 11, colors.lime, colors.red)
t:draw()

while true do
  local event, p1 = t:handleEvents(os.pullEvent())
  if event == "button_click" then
    t:toggleButton(p1)
    
    if p1 == "Shield" then
      toggleShield()
    else
      togglePower()
    end
  end
end