local const = {
  games = {
    {
      name = 'Sudoku',
      filename = 'sudoku',
    },
    {
      name = 'Minesweeper',
      filename = 'minesweeper'
    }
  },
  minesweeper = {
    difficulties = {
      [1] = { name = 'Easy', rows = 9, cols = 9, mines = 10 },
      [2] = { name = 'Medium', rows = 16, cols = 16, mines = 40 },
      [3] = { name = 'Hard', rows = 16, cols = 30, mines = 99 }
    }
  }
}

return const
