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
    RollBuddy:Print("/rb start")
    RollBuddy:Print("/rb setstart <text>")
    RollBuddy:Print("/rb startchan <y|1|both|off>")
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
    start = function()
        RollBuddy:StartRound()
    end,
    setstart = function(args)
        local text = table.concat(args, " ", 2)
        if text == "" then
            RollBuddy:Print("Usage: /rb setstart <text>")
            return
        end
        RollBuddy:SetStartMessage(text)
    end,
    startchan = function(args)
        local value = string.lower(args[2] or "")
        if value == "y" or value == "/y" then
            RollBuddy:SetStartChannelEnabled("say", true)
            RollBuddy:SetStartChannelEnabled("general", false)
            return
        end
        if value == "1" or value == "/1" then
            RollBuddy:SetStartChannelEnabled("say", false)
            RollBuddy:SetStartChannelEnabled("general", true)
            return
        end
        if value == "both" then
            RollBuddy:SetStartChannelEnabled("say", true)
            RollBuddy:SetStartChannelEnabled("general", true)
            return
        end
        if value == "off" then
            RollBuddy:SetStartChannelEnabled("say", false)
            RollBuddy:SetStartChannelEnabled("general", false)
            return
        end

        RollBuddy:Print("Usage: /rb startchan <y|1|both|off>")
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
