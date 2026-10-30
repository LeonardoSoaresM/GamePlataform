local const = require("const")
local helpers = require("helpers")

local availableGames = helpers.getAvailableGames(const.games)

local function showMenu()
    os.execute("clear")
    print("Arcade Platform\n")
    print("We currently have " .. #availableGames .. " available game(s).\n")

    for i, game in ipairs(availableGames) do
        print(i .. " - " .. game.name)
    end
    print("0 - Exit\n")

    io.write("Choose a game: ")
end

local function main()
    while true do
        showMenu()
        local choice = tonumber(io.read())

        if choice == 0 then
            print("\nExiting the Arcade. See you later!")
            break
        elseif choice and availableGames[choice] then
            local selectedGame = availableGames[choice]
            print("\nStarting " .. selectedGame.name .. "...\n")

            local gameModule = require(selectedGame.filename)
            if gameModule and type(gameModule.play) == "function" then
                gameModule.play()
            else
                print("Error: The game could not be started.")
            end

            print("\nPress ENTER to return to the menu...")
            io.read()
        else
            print("\nInvalid option! Press ENTER to try again.")
            io.read()
        end
    end
end

main()
