local function tokenize(message)
    local args = {}

    for word in string.gmatch(message or "", "%S+") do
        args[#args + 1] = word
    end

    return args
end

local function printHelp()
    RollBuddy:Print("Commands:")
    RollBuddy:Print("/rb - toggle main window")
    RollBuddy:Print("/rb settings - toggle settings window")
    RollBuddy:Print("/rb list")
    RollBuddy:Print("/rb add <min> <max> <multiplier>")
    RollBuddy:Print("/rb edit <index> <min> <max> <multiplier>")
    RollBuddy:Print("/rb remove <index>")
    RollBuddy:Print("/rb debugdb")
end

local handlers = {
    [""] = function()
        RollBuddy:ToggleWindow()
    end,
    settings = function()
        RollBuddy:ToggleSettingsWindow()
    end,
    list = function()
        RollBuddy:ListRanges()
    end,
    add = function(args)
        local minRoll = tonumber(args[2])
        local maxRoll = tonumber(args[3])
        local multiplier = tonumber(args[4])

        if not minRoll or not maxRoll or not multiplier then
            RollBuddy:Print("Usage: /rb add <min> <max> <multiplier>")
            return
        end

        RollBuddy:AddRange(minRoll, maxRoll, multiplier)
    end,
    edit = function(args)
        local index = tonumber(args[2])
        local minRoll = tonumber(args[3])
        local maxRoll = tonumber(args[4])
        local multiplier = tonumber(args[5])

        if not index or not minRoll or not maxRoll or not multiplier then
            RollBuddy:Print("Usage: /rb edit <index> <min> <max> <multiplier>")
            return
        end

        RollBuddy:EditRange(index, minRoll, maxRoll, multiplier)
    end,
    remove = function(args)
        local index = tonumber(args[2])

        if not index then
            RollBuddy:Print("Usage: /rb remove <index>")
            return
        end

        RollBuddy:RemoveRange(index)
    end,
    debugdb = function()
        RollBuddy:Print("DB table: " .. tostring(RollBuddy.db))
        RollBuddy:Print("rollRanges table: " .. tostring(RollBuddy.db.rollRanges))
        RollBuddy:Print("Range count: " .. tostring(#RollBuddy.db.rollRanges))
    end,
}

SLASH_ROLLBUDDY1 = "/rb"
SlashCmdList["ROLLBUDDY"] = function(msg)
    local args = tokenize(msg)
    local cmd = string.lower(args[1] or "")
    local handler = handlers[cmd]

    if not handler then
        printHelp()
        return
    end

    handler(args)
end
