local Board = {}

function Board.create(rows, columns, defaultValue)
  local board = {}
  board.rows = rows
  board.columns = columns
  board.data = {}

  for i=1,rows do
    board.data[i] = {}
    for j=1,columns do
      board.data[i][j] = defaultValue
    end
  end

  setmetatable(board, {
    __index = Board
  })
  return board
end

function Board:draw()
  local lines = {}
  for r = 1, self.rows do
    local rowChars = {}
      for c = 1, self.columns do
        table.insert(rowChars, tostring(self.data[r][c] or "."))
    end
    table.insert(lines, table.concat(rowChars, " "))
  end
  print(table.concat(lines, "\n"))
end

function Board:setValue(row, column, value)
  self.data[row][column] = value
end

function Board:getValue(row, column)
  return self.data[row][column]
end

return Board
