-- {program="aTreeFarm",version="1.04b",date="2018-01-07"}
---------------------------------------
-- aTreeFarm           by Kaikaku
-- 2018-01-07, v1.04   bugfix (turtle start position)
-- 2018-01-05, v1.03   bugfix (turtle digged drop chest)
-- 2017-12-02, v1.02   start with craft fuel and empty to allow tHome
-- 2015-01-31, v1.01   fixed initial refuelling
-- 2015-01-31, v1.00   finalized UI + counter
-- 2015-01-30, v0.80   auto set-up option
-- 2015-01-26, v0.70   preparing for video
-- 2014-01-12, v0.61   replant limited tries
-- 2014-01-04, v0.60   redstone stop
-- 2013-12-15, v0.51   initial
---------------------------------------
---------------------------------------
---- DESCRIPTION ----------------------
---------------------------------------
-- Turtle-automated tree farm.
-- Details see information during program
--   execution or YouTube video.
---------------------------------------
---- PARAMETERS -----------------------
---------------------------------------
local cVersion = "1.04"
local cPrgName = "aTreeFarm"
local cMinFuel = 960 * 2 -- 2 stacks of planks

local minRandomCheckSapling = 0.1 -- below this will check replant
local actRandomCheckSapling = minRandomCheckSapling * 2
local cIncreaseCheckSapling_Sapling = 0.02
local cIncreaseCheckSapling_Stub = 0.04
local cMaxCheckSapling = 0.6
local strC = "tReeTreESdig!diG;-)FaRmKaIKAKUudIgYdIgyTreEAndsOrRygUYsd"

local cSlotChest = 16 -- chest for crafty turtle
local cCraftRefuelMaxItems = 32 -- use how many logs to refuel at max
local cSlotRefuel = 15 -- where to put fuel
local cExtraDigUp = 1 -- go how many extra levels to reach jungle branches
local cLoopEnd = 56 -- one loop
local cWaitingTime = 20 -- if redstone signal in back is on

---------------------------------------
---- VARIABLES ------------------------
---------------------------------------
local strC_now = ""
local strC_next = ""

local tmpResult = ""
local blnAskForParameters = true
local blnShowUsage = false
local blnAutoSetup = false
local strSimpleCheck = "Press enter to start:"
local intCounter = 0
local maxCounter = 0

---------------------------------------
---- tArgs ----------------------------
---------------------------------------
local tArgs = {...}
if #tArgs >= 1 then -- no error check
    blnAskForParameters = false
    if tArgs[1] == "help" then
        blnShowUsage = true
    end
    if tArgs[1] == "setup" then
        blnAutoSetup = true
    end
    if tArgs[1] == "set-up" then
        blnAutoSetup = true
    end
    if tonumber(tArgs[1]) ~= nil then
        maxCounter = tonumber(tArgs[1])
    end
end

if blnShowUsage then
    print("+-------------------------------------+")
    print("  " .. cPrgName .. ", by Kaikaku")
    print("+-------------------------------------+")
    print("Usage: aTreeFarm [setup/set-up]")
    print("   or: aTreeFarm [maxCounter]")
    print("setup or set-up:")
    print("   Will start auto set-up")
    print("maxCounter:")
    print("   0=will farm infinitely")
    print("   x=will farm x rounds")
    print("More details on YouTube ;)")
    return
end

---------------------------------------
-- BASIC FUNCTIONS FOR TURTLE CONTROL -
---------------------------------------
local function gf(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.forward() do
        end
    end
end
local function gb(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.back() do
        end
    end
end
local function gu(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.up() do
        end
    end
end
local function gd(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.down() do
        end
    end
end
local function gl(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.turnLeft() do
        end
    end
end
local function gr(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.turnRight() do
        end
    end
end
local function pf(n)
    -- moves backwards if n>1
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        if i ~= 1 then
            gb()
        end
        turtle.place()
    end
end
local function pu()
    turtle.placeUp()
end
local function pd()
    turtle.placeDown()
end
local function df()
    return turtle.dig()
end
local function du()
    turtle.digUp()
end
local function dd()
    turtle.digDown()
end
local function sf()
    turtle.suck()
end
local function su()
    turtle.suckUp()
end
local function sd(n)
    if n == nil then
        while turtle.suckDown() do
        end
    else
        for i = 1, n do
            turtle.suckDown()
        end
    end
end
local function Df()
    turtle.drop()
end
local function Du(n)
    if n == nil then
        n = 64
    end
    turtle.dropUp(n)
end
local function Dd(n)
    if n == nil then
        n = 64
    end
    turtle.dropDown(n)
end
local function ss(s)
    turtle.select(s)
end

local function askForInputText(textt)
    local at = ""
    -- check prompting texts
    if textt == nil then
        textt = "Enter text:"
    end

    -- ask for input
    write(textt)
    at = read()
    return at
end

local function checkFuel()
    local tmp = turtle.getFuelLevel()
    return tmp
end

function checkRefuel(minFuel, slotFuel)
    if slotFuel == nil then
        slotFuel = 16
    end
    if minFuel == nil then
        minFuel = 1000
    end
    local tmpFuel = 0
    tmpFuel2 = 0
    local tmpItems = 65 -- turtle.getItemCount(slotFuel)
    local cSleep = 5

    -- step 1 check if more fuel is required
    tmpFuel = turtle.getFuelLevel()
    tmpFuel2 = tmpFuel - 1 -- triggers print at least once
    if tmpFuel < minFuel then
        ss(slotFuel)
        -- step 2 refuel loop
        while tmpFuel < minFuel do
            -- step 2.1 need to update fuel level?
            if tmpFuel2 ~= tmpFuel then -- tmpItems~=turtle.getItemCount(slotFuel) then
                -- fuel still too low and there have been items consumed
                print("Need more fuel (" .. tmpFuel .. "/" .. minFuel .. ") in slot " .. slotFuel)
            end
            -- step 2.2 try to refuel
            if tmpItems > 0 then
                -- try to refuel this items
                turtle.refuel()
            else
                os.sleep(cSleep)
            end
            -- step 2.3 update variables
            tmpItems = turtle.getItemCount(slotFuel)
            tmpFuel2 = tmpFuel
            tmpFuel = turtle.getFuelLevel()
        end
    end
    -- step 3 either no need to refuel
    --        or successfully refuelled
    print("Fuel level ok  (" .. tmpFuel .. "/" .. minFuel .. ")")
end

---------------------------------------
---- functions ------------------------
---------------------------------------

local function cutTree()
    local tmpExtraDigUp = cExtraDigUp

    ---- assumptions
    -- turtle faces trunk one block below bottom
    ---- variables
    local intUpCount = 0
    local intFace = 0 -- -1=left, 1=right
    local blnDigSomething = false

    term.write("  cutting tree: ")

    -- get into tree column
    df()
    while not turtle.forward() do
        df()
    end
    gr()
    df()
    gl()
    df()
    gl()
    df()
    local intFace = -1

    -- cut and go up
    repeat
        blnDigSomething = false
        du()
        while not turtle.up() do
            du()
        end
        blnDigSomething = df() or blnDigSomething
        if intFace == -1 then
            gr()
            blnDigSomething = df() or blnDigSomething
            gr()
        elseif intFace == 1 then
            gl()
            blnDigSomething = df() or blnDigSomething
            gl()
        end
        intFace = intFace * -1
        blnDigSomething = df() or blnDigSomething
        intUpCount = intUpCount + 1
        term.write(".")

        -- check for 2 conditions
        -- either
        -- 1) nothing above the turtle
        -- or
        -- 2) nothing dig on the other columns blnDigSomething
        if not (turtle.detectUp() or blnDigSomething) then
            tmpExtraDigUp = tmpExtraDigUp - 1
        else
            tmpExtraDigUp = cExtraDigUp -- restore it
        end
    until tmpExtraDigUp < 0 -- not (turtle.detectUp() or blnDigSomething) ----- NOT kai_2

    -- go off tree column
    if intFace == -1 then
        gl()
    elseif intFace == 1 then
        gr()
    end
    df()
    while not turtle.forward() do
        df()
    end
    gl()
    intFace = 0

    intFace = 1 -- 1=forward,-1=backwards
    -- go back down
    -- hint: only digging front and back in order
    --       to not cut into larger neighbouring,
    --       as this may leave upper tree parts left
    for i = 1, intUpCount + 1 do
        dd()
        df()
        gl(2)
        df()
        intFace = intFace * -1
        while not turtle.down() do
            dd()
        end
    end
    if intFace == 1 then
        gl()
    elseif intFace == -1 then
        gr()
    end
    sf()
    df()
    term.write(".")
    print(" done!")

    -- plant new
    plantTree()
    while not turtle.up() do
        du()
    end
    sd()
end

---------------------------------------
function plantTree()
    local tmpCount = 0
    ---- assumptions
    -- turtle faces place to plant

    -- check for enough saplings
    sf()
    if turtle.getItemCount(1) > 1 then
        -- plant
        print("  plant new sapling")
        while not turtle.place() do
            print("  hard to plant here...")
            tmpCount = tmpCount + 1
            if tmpCount > 3 then
                break
            end
            os.sleep(1)
        end -- NOT kai_2
    else
        -- error
        print("  Out of saplings...") -- prog name
        os.sleep(5)
        actRandomCheckSapling = cMaxCheckSapling
        return
    end
end

---------------------------------------
local function replantStub()
    ss(2) -- compare with wood in slot 2
    if turtle.compare() then
        -- assumption: there is only a stub left, so replant
        -- if there is a tree on top of it, it will be harvested next round
        print("  Replanting a stub")
        df()
        ss(1)
        if pf() then
            actRandomCheckSapling = actRandomCheckSapling + cIncreaseCheckSapling_Stub
        else
            print("    failure!")
        end
    else
        ss(1)
    end
end
local function eS(sI, sA, eA)
    local sO = ""
    local sR = ""
    if sA == nil then
        sA = 1
    end
    if eA == nil then
        eA = string.len(sI)
    end
    for i = sA, eA, 1 do
        sO = string.sub(sI, i, i)
        if sR ~= "" then
            break
        end
        if sO == "a" then
            gl()
        elseif sO == "d" then
            gr()
        else
            while not turtle.forward() do
                df()
            end
        end
    end
    return sR
end

---------------------------------------
local function randomReplant()
    local intSuccess = 0
    if turtle.getItemCount(1) > 10 then
        -- try to plant
        while not turtle.down() do
            dd()
        end
        sf()
        gl()
        sf()
        if turtle.place() then
            actRandomCheckSapling = actRandomCheckSapling + cIncreaseCheckSapling_Sapling
        else
            if turtle.detect() then
                replantStub()
            end
        end
        gl()
        sf()
        gl()
        sf()
        if turtle.place() then
            actRandomCheckSapling = actRandomCheckSapling + cIncreaseCheckSapling_Sapling
        else
            if turtle.detect() then
                replantStub()
            end
        end
        gl()
        sf()
        while not turtle.up() do
            du()
        end
        -- ensure min probability and max 100%
        actRandomCheckSapling = math.max(actRandomCheckSapling - 0.01, minRandomCheckSapling)
        actRandomCheckSapling = math.min(actRandomCheckSapling, cMaxCheckSapling)
        print((actRandomCheckSapling * 100) .. "% check probability")
    else
        -- extra suck
        while not turtle.down() do
            dd()
        end
        sf()
        gr()
        sf()
        gr()
        sf()
        gr()
        sf()
        gr()
        sf()
        while not turtle.up() do
            du()
        end
        sd()
    end
end

---------------------------------------
local function craftFuel()
    local tmpFuelItems = turtle.getItemCount(2)

    -- step 1 need fuel?
    if (turtle.getFuelLevel() < cMinFuel) and (turtle.getItemCount(cSlotChest) == 1) then
        -- no refuelling if not exactly 1 item in slot cSlotChest (=chest)
        print("Auto refuel    (" .. turtle.getFuelLevel() .. "/" .. cMinFuel .. ") ...")

        -- step 2 enough mats to refuel?
        --        assumption: slot 2 has wood
        if tmpFuelItems > 1 then
            -- step 2 store away stuff!
            ss(cSlotChest)
            while not turtle.placeUp() do
                du()
            end

            for i = 1, 15, 1 do
                ss(i)
                if i ~= 2 then
                    Du()
                else
                    -- cCraftRefuelMaxItems
                    Du(math.max(1, turtle.getItemCount(2) - cCraftRefuelMaxItems)) -- to keep the wood
                end
            end

            -- step 3 craft planks!
            turtle.craft()

            -- step 4 refuel!
            for i = 1, 16, 1 do
                ss(i)
                turtle.refuel()
            end
            print("New fuel level (" .. turtle.getFuelLevel() .. "/" .. cMinFuel .. ")")

            -- step 5 get back stuff!
            ss(1) -- su(64)
            while turtle.suckUp() do
            end
            ss(cSlotChest)
            du()
            ss(1)
        else
            print("Ups, not enough wood for auto refuel!")
        end
    end
end

---------------------------------------
local function emptyTurtle()
    print("  Drop what I've harvested!")
    while not turtle.down() do
        dd()
    end
    ss(2)

    if turtle.compareTo(1) then
        print("Error: Ups, in slot 2 is the same as in slot 1??")
        -- Dd()
    else
        -- if slot 2 has other item (wood) than slot 1
        --   keep one of them for comparison
        if turtle.getItemCount(2) > 1 then
            Dd(math.max(turtle.getItemCount(2) - 1, 0))
        end
    end
    for i = 3, 15, 1 do
        -- assumption slot 16 contains a chest
        ss(i)
        Dd()
    end
    os.sleep(0)
    ss(1)
end

---------------------------------------
---- main -----------------------------
---------------------------------------
-- step 0 info and initial check
term.clear()
term.setCursorPos(1, 1)
repeat
    print("+-------------------------------------+")
    print("| aTreeFarm " .. cVersion .. ", by Kaikaku (1/2)    |")
    print("+-------------------------------------+")
    print("| Farm set-up: Place crafty felling   |")
    print("|   turtle down (e.g. bottom left     |")
    print("|   corner of chunk). Run program with|")
    print("|   parameter 'setup' (one time).     |")
    print("| Materials for auto set-up:          |")
    print("|   slot 3: chest   (1)               |")
    print("|   slot 4: cobble  (47)              |")
    print("|   slot 5: torches (8)               |")
    print("+-------------------------------------+")

    if blnAutoSetup then
        if turtle.getItemCount(3) ~= 1 or turtle.getItemCount(4) < 47 or turtle.getItemCount(5) < 8 then
            -- inventory not ready for set-up
            strSimpleCheck = "Fill in slots 3-5 and press enter:"
        else
            strSimpleCheck = "Press enter to start:"
        end
    else
        strSimpleCheck = "Press enter to start:"
    end
    if not blnAskForParameters and strSimpleCheck == "Press enter to start:" then
        break
    end
until askForInputText(strSimpleCheck) == "" and strSimpleCheck == "Press enter to start:"

term.clear()
term.setCursorPos(1, 1)
repeat
    print("+-------------------------------------+")
    print("| aTreeFarm " .. cVersion .. ", by Kaikaku (2/2)    |")
    print("+-------------------------------------+")
    print("| Running the farm:                   |")
    print("|   Felling turtle sits above chest   |")
    print("|   (as after running set-up). Turtle |")
    print("|   needs some initial fuel to start. |")
    print("| Turtle inventory:                   |")
    print("|   slot  1: saplings          (20+x) |")
    print("|   slot  2: wood from sapling (1+x)  |")
    print("|   slot 16: chest             (1)    |")
    print("+-------------------------------------+")

    if turtle.getItemCount(1) < 11 or turtle.getItemCount(2) == 0 or turtle.getItemCount(16) ~= 1 then
        -- inventory not ready
        strSimpleCheck = "Provide materials and press enter:"
    else
        strSimpleCheck = "Press enter to start:"
    end
    -- strSimpleCheck="Press enter to start:"
    if not blnAskForParameters and strSimpleCheck == "Press enter to start:" then
        break
    end
    if blnAutoSetup then
        strSimpleCheck = "Press enter to start:"
    end
until askForInputText(strSimpleCheck) == "" and strSimpleCheck == "Press enter to start:"

---------------------------------------
---- set-up farm ----------------------
---------------------------------------
-- set-up = not running the farm
if blnAutoSetup then
    write("Setting up tree farm...")
    checkRefuel(cMinFuel, cSlotRefuel)
    -- chest
    gf(3)
    gr()
    gf(3)
    gl()
    ss(3)
    dd()
    pd()
    -- path
    ss(4)
    for i = 1, 9, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 3, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 6, 1 do
        gf()
        dd()
        pd()
    end
    gl()
    for i = 1, 3, 1 do
        gf()
        dd()
        pd()
    end
    gl()
    for i = 1, 6, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 3, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 9, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 8, 1 do
        gf()
        dd()
        pd()
    end
    -- torches
    ss(5)
    gf(2)
    gl()
    pf()
    gu()
    gb(10)
    pd()
    gl()
    gf(5)
    pd()
    gf()
    pd()
    gf(5)
    pd()
    gr()
    gf(11)
    pd()
    gb(3)
    gr()
    gf(3)
    pd()
    gf(5)
    pd()
    gf(2)
    gr()
    gb(2)
    gd()
    print(" done!")
    print("You can now run the tree farm with: ", cPrgName)
    return
end

---------------------------------------
---- tree farm ------------------------
---------------------------------------
strC_next = string.sub(strC, 1, 1)

-- initial up
while not turtle.up() do
    du()
end

while true do

    -- step 6 need to craft some fuel?
    craftFuel()

    -- step 7 empty into chest
    emptyTurtle()

    -- step 0 check exit
    if maxCounter > 0 then
        if intCounter == maxCounter then
            print("Completed all ", maxCounter, "  farming rounds.")
            print("I'm awaiting new commands, master!")
            -- while not turtle.up() do du() end
            return
        end
    end

    -- step 1 check fuel
    checkRefuel(cMinFuel, cSlotRefuel)

    -- step 2 wait if redstone signal
    while rs.getInput("back") do
        print("Waiting due to redstone signal ", cWaitingTime, "s.")
        os.sleep(cWaitingTime)
    end

    -- step 3 new round
    while not turtle.up() do
        du()
    end
    ss(1)
    intCounter = intCounter + 1
    print("Starting round ", intCounter, " with " .. turtle.getItemCount(1) .. " saplings.")

    for i = 1, cLoopEnd, 1 do

        -- update commands
        strC_now = strC_next
        if i < cLoopEnd then
            strC_next = string.sub(strC, i + 1, i + 1)
        else
            strC_next = string.sub(strC, 1, 1)
        end

        -- step 4 one step on the road
        tmpResult = eS(strC, i, i)
        if tmpResult ~= "" then
            print("found special command: " .. tmpResult)
        end

        -- step 5 check for blocks
        -- step 5.1 check left hand side
        if strC_now ~= "a" and strC_next ~= "a" then
            -- now  a=>just turned left
            -- next a=>will turned left
            gl()
            if turtle.detect() then
                cutTree()
            end
            gr()
        end
        -- step 5.2 check right hand side
        if strC_now ~= "d" and strC_next ~= "d" then
            -- now  d=>just turned right
            -- next d=>will turn right
            gr()
            if turtle.detect() then
                cutTree()
            end
            gl()
        end
        sd()

        if math.random() <= actRandomCheckSapling then
            if strC_now ~= "d" and strC_now ~= "a" then
                randomReplant()
            end
        end
    end
end
