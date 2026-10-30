local const = require("const")

local Minesweeper = {}

local function isValid(r, c, rows, cols)
  return r >= 1 and r <= rows and c >= 1 and c <= cols
end

local function placeMines(grid, rows, cols, numMines, firstR, firstC)
  local placed = 0
  while placed < numMines do
    local r = math.random(1, rows)
    local c = math.random(1, cols)
    if grid[r][c] ~= 'M' and not (r == firstR and c == firstC) then
      grid[r][c] = 'M'
      placed = placed + 1
    end
  end
end

local function calculateNumbers(grid, rows, cols)
  for r = 1, rows do
    for c = 1, cols do
      if grid[r][c] ~= 'M' then
        local count = 0
        for dr = -1, 1 do
          for dc = -1, 1 do
            local nr, nc = r + dr, c + dc
            if isValid(nr, nc, rows, cols) and grid[nr][nc] == 'M' then
              count = count + 1
            end
          end
        end
        grid[r][c] = tostring(count)
      end
    end
  end
end

local function revealCell(grid, visibleGrid, r, c, rows, cols)
  if not isValid(r, c, rows, cols) or visibleGrid[r][c] ~= 'hidden' then
    return
  end

  visibleGrid[r][c] = 'revealed'

  if grid[r][c] == '0' then
    for dr = -1, 1 do
      for dc = -1, 1 do
        revealCell(grid, visibleGrid, r + dr, c + dc, rows, cols)
      end
    end
  end
end

local function checkWin(visibleGrid, grid, rows, cols, totalMines)
  local hiddenCount = 0
  for r = 1, rows do
    for c = 1, cols do
      if visibleGrid[r][c] == 'hidden' or visibleGrid[r][c] == 'flagged' then
        hiddenCount = hiddenCount + 1
      end
    end
  end
  return hiddenCount == totalMines
end

function Minesweeper.play()
  os.execute("clear")
  print("Minesweeper\n")
  print("Select Difficulty:")
  print("1 - Easy")
  print("2 - Medium")
  print("3 - Hard")
  io.write("\nChoice: ")

  local choice = io.read()
  local diffLevel = tonumber(string.match(choice, "%d+"))

  local config = const.minesweeper.difficulties[diffLevel]
  if not config then
    print("Invalid difficulty. Defaulting to Easy.")
    config = const.minesweeper.difficulties[1]
  end

  local rows, cols, totalMines = config.rows, config.cols, config.mines
  local grid = {}
  local visibleGrid = {}

  for r = 1, rows do
    grid[r] = {}
    visibleGrid[r] = {}
    for c = 1, cols do
      grid[r][c] = '0'
      visibleGrid[r][c] = 'hidden'
    end
  end

  local isFirstClick = true
  local gameOver = false
  local flagsPlaced = 0
  local startTime = os.time()

  while not gameOver do
    os.execute("clear")
    local elapsed = os.difftime(os.time(), startTime)

    print("Minesweeper (" .. config.name .. ")")
    print(string.format("Time: %ds | Flags: %d/%d", elapsed, flagsPlaced, totalMines))
    print("\n")

    io.write("    ")
    for c = 1, cols do io.write(string.format("%02d ", c)) end
    print("\n")

    for r = 1, rows do
      io.write(string.format("%02d  ", r))
      for c = 1, cols do
        if visibleGrid[r][c] == 'hidden' then
          io.write("[ ]")
        elseif visibleGrid[r][c] == 'flagged' then
          io.write("[F]")
        elseif visibleGrid[r][c] == 'revealed' then
          if grid[r][c] == 'M' then
            io.write(" * ")
          elseif grid[r][c] == '0' then
            io.write(" . ")
          else
            io.write(" " .. grid[r][c] .. " ")
          end
        end
      end
      print()
    end
    print("\n")

    print("Enter action (R = Reveal, F = Flag) and coordinates.")
    print("Example: 'R 5 5' or 'F 2 3'")
    io.write("Command: ")

    local input = io.read()
    local action, r, c = string.match(input:upper(), "([RF])%s+(%d+)%s+(%d+)")
    r, c = tonumber(r), tonumber(c)

    if action and r and c and isValid(r, c, rows, cols) then
      if action == 'R' then
        if visibleGrid[r][c] == 'flagged' then
          print("Cell is flagged! Unflag it first.")
        else
          if isFirstClick then
            placeMines(grid, rows, cols, totalMines, r, c)
            calculateNumbers(grid, rows, cols)
            isFirstClick = false
          end

          if grid[r][c] == 'M' then
            visibleGrid[r][c] = 'revealed'
            gameOver = true
            print("\nBOOM! You hit a mine. Game Over.")
          else
            revealCell(grid, visibleGrid, r, c, rows, cols)
            if checkWin(visibleGrid, grid, rows, cols, totalMines) then
              gameOver = true
              local finalTime = os.difftime(os.time(), startTime)
              print(string.format("\nCongratulations! You cleared the minefield in %ds.", finalTime))
            end
          end
        end
      elseif action == 'F' then
        if visibleGrid[r][c] == 'hidden' then
          visibleGrid[r][c] = 'flagged'
          flagsPlaced = flagsPlaced + 1
        elseif visibleGrid[r][c] == 'flagged' then
          visibleGrid[r][c] = 'hidden'
          flagsPlaced = flagsPlaced - 1
        end
      end
    else
      print("Invalid input format. Try again.")
    end
  end
end

return Minesweeper
