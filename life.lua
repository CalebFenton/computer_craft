CELL_ALIVE = "o"
CELL_BIRTHING = "-"
CELL_EMPTY = "."
CELL_DYING = "x"
ITERATION_DELAY = 0.1

function table.equals(array1, array2)
    if #array1 ~= #array2 then
        return false
    end
    for i, v in pairs(array1) do
        if type(v) == "table" then
            return table.equals(v, array2[i])
        elseif v ~= array2[i] then
            return false
        end
    end
    return true
end

function table.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function table.deep_copy(datatable)
    local tblRes={}
    if type(datatable)=="table" then
      for k,v in pairs(datatable) do
        tblRes[table.deep_copy(k)] = table.deep_copy(v)
      end
    else
      tblRes=datatable
    end
    return tblRes
end

-- @param width number
-- @param height number
-- @return array
function build_game(width, height)
    local game = {}
    width = width or 16
    height = height or 16
    for x = 1, width do
        game[x] = {}
        for y = 1, height do
            if math.random() >= 0.5 then
                game[x][y] = CELL_ALIVE
            else
                game[x][y] = CELL_EMPTY
            end
        end
    end
    return game
end

function print_game(game)
    term.clear()
    for y = 1, #game[1] do
        for x = 1, #game do
            --io.write("(" .. x .. "," .. y .. ")" .. (game[x][y] and 1 or 0) .. " ")
            -- io.write(game[x][y]  .. count_neighbors(game, x, y) .. " ")
            io.write(game[x][y])
        end
        io.write("\n")
    end
    io.flush()
end

function count_neighbors(game, x, y)
    local count = 0
    for i = math.max(x - 1, 1), math.min(x + 1, #game) do
        for j = math.max(y - 1, 1), math.min(y + 1, #game[i]) do
            if i ~= x or j ~= y then
                if game[i][j] == CELL_ALIVE then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function partial_iterate_game(game)
    local original_game = table.deep_copy(game)
    for x = 1, #game do
        for y = 1, #game[x] do
            count = count_neighbors(original_game, x, y)
            --print(x .. "," .. y .. "=" .. count)
            if game[x][y] == CELL_EMPTY then
                if count == 3 then
                    game[x][y] = CELL_BIRTHING
                end
            elseif game[x][y] == CELL_ALIVE then
                if count <= 1 or count >= 4 then
                    game[x][y] = CELL_DYING
                end
            end
        end
    end
end

function finish_iterate_game(game)
    for x = 1, #game do
        for y = 1, #game[x] do
            if game[x][y] == CELL_BIRTHING then
                game[x][y] = CELL_ALIVE
            elseif game[x][y] == CELL_DYING then
                game[x][y] = CELL_EMPTY
            end
        end
    end
end

function start()
    local game = build_game()
    local run = 10
    local history = { table.deep_copy(game) }
    local current_idx = 1
    local previous_idx = nil
    while run > 0 do
        print_game(game)
        sleep(0.1)
        -- io.read()
        partial_iterate_game(game)
        print_game(game)
        sleep(0.1)
        -- io.read()
        finish_iterate_game(game)

        print_game(game)
        sleep(0.1)

        previous_idx = current_idx
        current_idx = current_idx + 1
        if current_idx > 3 then
            current_idx = 1
        end
        history[current_idx] = table.deep_copy(game)
        if table.equals(history[current_idx], history[previous_idx]) then
            print("not changing", current_idx, previous_idx)
            run = 0
        elseif #history == 3 and table.equals(history[1], history[3]) then
            print("flip flopity", current_idx, previous_idx)
            run = run - 1
        else
            --sleep(ITERATION_DELAY)
        end
    end

    -- print("done running")
end

while true do
    --debug.debug()
    start()
    sleep(3)
end
