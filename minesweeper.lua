local const = require("const")
local Board = require("board")
math.randomseed(os.time())
local Minesweeper = {}

local msConfig
for _, game in ipairs(const.games) do
  if game.filename == 'minesweeper' then
    msConfig = game
    break
  end
end

function Minesweeper.create(diffLevel, cheatMode)
  local game = {}
  setmetatable(game, {
    __index = Minesweeper
  })

  game.config = msConfig.difficulties[diffLevel]
  game.cheatMode = cheatMode
  game.rows = game.config.rows
  game.cols = game.config.cols
  game.totalMines = game.config.mines

  game.logicGrid = Board.create(game.rows, game.cols, '0')
  game.visibleGrid = Board.create(game.rows, game.cols, 'hidden')

  game.isFirstClick = true
  game.gameOver = false
  game.flagsPlaced = 0
  game.startTime = os.time()

  return game
end

function Minesweeper:isValid(r, c)
  return r >= 1 and r <= self.rows and c >= 1 and c <= self.cols
end

function Minesweeper:placeMines(firstR, firstC)
  local placed = 0
  while placed < self.totalMines do
    local r = math.random(1, self.rows)
    local c = math.random(1, self.cols)
    if self.logicGrid:getValue(r, c) ~= '*' and not (r == firstR and c == firstC) then
      self.logicGrid:setValue(r, c, '*')
      placed = placed + 1
    end
  end
end

function Minesweeper:calculateNumbers()
  for r = 1, self.rows do
    for c = 1, self.cols do
      if self.logicGrid:getValue(r, c) ~= '*' then
        local count = 0
        for dr = -1, 1 do
          for dc = -1, 1 do
            local nr, nc = r + dr, c + dc
            if self:isValid(nr, nc) and self.logicGrid:getValue(nr, nc) == '*' then
              count = count + 1
            end
          end
        end
        self.logicGrid:setValue(r, c, tostring(count))
      end
    end
  end
end

function Minesweeper:revealCell(r, c)
  if not self:isValid(r, c) or self.visibleGrid:getValue(r, c) ~= 'hidden' then
    return
  end

  self.visibleGrid:setValue(r, c, 'revealed')

  if self.logicGrid:getValue(r, c) == '0' then
    for dr = -1, 1 do
      for dc = -1, 1 do
        self:revealCell(r + dr, c + dc)
      end
    end
  end
end

function Minesweeper:checkWin()
  local hiddenCount = 0
  for r = 1, self.rows do
    for c = 1, self.cols do
      local state = self.visibleGrid:getValue(r, c)
      if state == 'hidden' or state == 'flagged' then
        hiddenCount = hiddenCount + 1
      end
    end
  end
  return hiddenCount == self.totalMines
end

function Minesweeper:getCheatMove()
  local frontier = {}
  local seen = {}

  for r = 1, self.rows do
    for c = 1, self.cols do
      if self.visibleGrid:getValue(r, c) == 'revealed' and self.logicGrid:getValue(r, c) ~= '*' and self.logicGrid:getValue(r, c) ~= '0' then
        for dr = -1, 1 do
          for dc = -1, 1 do
            local nr, nc = r + dr, c + dc
            if self:isValid(nr, nc) and self.visibleGrid:getValue(nr, nc) == 'hidden' then
              local key = nr .. "," .. nc
              if not seen[key] then
                seen[key] = true
                table.insert(frontier, {r = nr, c = nc})
              end
            end
          end
        end
      end
    end
  end

  if #frontier == 0 then
    for r = 1, self.rows do
      for c = 1, self.cols do
        if self.visibleGrid:getValue(r, c) == 'hidden' and self.logicGrid:getValue(r, c) ~= '*' then
          return r, c, 'R'
        end
      end
    end
  end

  local target = frontier[math.random(1, #frontier)]
  if self.logicGrid:getValue(target.r, target.c) == '*' then
    return target.r, target.c, 'F'
  else
    return target.r, target.c, 'R'
  end
end

function Minesweeper:run()
  while not self.gameOver do
    os.execute("clear")
    local elapsed = os.difftime(os.time(), self.startTime)

    print("Minesweeper (" .. self.config.name .. ")")
    if self.cheatMode then
      print(">>> AUTO-SOLVER ACTIVE <<<")
    end
    print(string.format("Time: %ds | Flags: %d/%d", elapsed, self.flagsPlaced, self.totalMines))
    print()

    io.write("    ")
    for c = 1, self.cols do io.write(string.format("%02d ", c)) end
    print("\n")

    for r = 1, self.rows do
      io.write(string.format("%02d  ", r))
      for c = 1, self.cols do
        local vis = self.visibleGrid:getValue(r, c)
        local val = self.logicGrid:getValue(r, c)

        if vis == 'hidden' then
          io.write("[ ]")
        elseif vis == 'flagged' then
          io.write("[F]")
        elseif vis == 'revealed' then
          if val == '*' then
            io.write(" * ")
          elseif val == '0' then
            io.write(" . ")
          else
            io.write(" " .. val .. " ")
          end
        end
      end
      print()
    end
    print("\n")

    local action, r, c

    if self.cheatMode then
      os.execute("sleep 0.3")
      r, c, action = self:getCheatMove()
      print(string.format("Auto-Solver played: %s at %02d, %02d", action, r, c))
      os.execute("sleep 0.5")
    else
      print("Enter action (R = Reveal, F = Flag) and coordinates.")
      print("Example: 'R 5 5' or 'F 2 3'")
      io.write("Command: ")

      local input = io.read()
      if input then
        action, r, c = string.match(input:upper(), "([RF])%s+(%d+)%s+(%d+)")
        r, c = tonumber(r), tonumber(c)
      end
    end

    if action and r and c and self:isValid(r, c) then
      if action == 'R' then
        if self.visibleGrid:getValue(r, c) == 'flagged' then
          print("Cell is flagged! Unflag it first.")
          os.execute("sleep 1")
        else
          if self.isFirstClick then
            self:placeMines(r, c)
            self:calculateNumbers()
            self.isFirstClick = false
          end

          if self.logicGrid:getValue(r, c) == '*' then
            self.visibleGrid:setValue(r, c, 'revealed')
            self.gameOver = true
            print("\nBOOM! You hit a mine. Game Over.")
          else
            self:revealCell(r, c)
            if self:checkWin() then
              self.gameOver = true
              local finalTime = os.difftime(os.time(), self.startTime)
              print(string.format("\nCongratulations! You cleared the minefield in %ds.", finalTime))
            end
          end
        end
      elseif action == 'F' then
        if self.visibleGrid:getValue(r, c) == 'hidden' then
          self.visibleGrid:setValue(r, c, 'flagged')
          self.flagsPlaced = self.flagsPlaced + 1
        elseif self.visibleGrid:getValue(r, c) == 'flagged' then
          self.visibleGrid:setValue(r, c, 'hidden')
          self.flagsPlaced = self.flagsPlaced - 1
        end
      end
    else
      if not self.cheatMode then
        print("Invalid input format. Try again.")
        os.execute("sleep 1")
      end
    end
  end
end

function Minesweeper.play()
  os.execute("clear")
  print("Minesweeper\n")
  print("Select Difficulty:")
  print("1 - Easy")
  print("2 - Medium")
  print("3 - Hard")
  print("\n(Tip: Append 'c' to enable Auto-Solver Cheat, e.g., '1c')")
  io.write("Choice: ")

  local choice = io.read()
  local diffLevel = tonumber(string.match(choice, "%d"))
  local cheatMode = string.match(choice, "c")

  if not diffLevel or not msConfig.difficulties[diffLevel] then
    print("Invalid difficulty. Defaulting to Easy.")
    diffLevel = 1
  end

  local game = Minesweeper.create(diffLevel, cheatMode)
  game:run()
end

return Minesweeper
