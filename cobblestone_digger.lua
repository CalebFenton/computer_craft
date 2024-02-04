function isInventoryFull()
    for i = 1,16 do
        if turtle.getItemSpace(i) > 0 then
            return false
        end
    end
    return true
end

while true do
    while not isInventoryFull() do
        turtle.dig()
        sleep(1)
    end
    print("inventory full; waiting")
    sleep(10)
end

