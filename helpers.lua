local helpers = {}

function readNumber(message, min, max, err)
  local number
  while not number do
    io.write(message)
    number = tonumber(io.read())
    if not number or number < min or number > max then
      print(err)
      number = nil
    end
  end
  return number
end

function gameExists(moduleName)
    local file = io.open(moduleName .. ".lua", "r")
    if file then
        file:close()
        return true
    end
    return false
end

function helpers.getAvailableGames(gamesList)
    local available = {}
    for _, game in ipairs(gamesList) do
        if gameExists(game.filename) then
            table.insert(available, game)
        end
    end
    return available
end

return helpers
