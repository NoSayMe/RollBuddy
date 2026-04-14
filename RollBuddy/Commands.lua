SLASH_ROLLBUDDY1 = "/rb"
SlashCmdList["ROLLBUDDY"] = function(msg)
    local args = {}

    for word in string.gmatch(msg or "", "%S+") do
        table.insert(args, word)
    end

    local cmd = string.lower(args[1] or "")

    if cmd == "" then
        RollBuddy:ToggleWindow()
        return
    end

    if cmd == "settings" then
        RollBuddy:ToggleSettingsWindow()
        return
    end

    if cmd == "list" then
        RollBuddy:ListRanges()
        return
    end

    if cmd == "add" then
        local minRoll = tonumber(args[2])
        local maxRoll = tonumber(args[3])
        local multiplier = tonumber(args[4])

        if not minRoll or not maxRoll or not multiplier then
            RollBuddy:Print("Usage: /rb add <min> <max> <multiplier>")
            return
        end

        RollBuddy:AddRange(minRoll, maxRoll, multiplier)
        return
    end

    if cmd == "edit" then
        local index = tonumber(args[2])
        local minRoll = tonumber(args[3])
        local maxRoll = tonumber(args[4])
        local multiplier = tonumber(args[5])

        if not index or not minRoll or not maxRoll or not multiplier then
            RollBuddy:Print("Usage: /rb edit <index> <min> <max> <multiplier>")
            return
        end

        RollBuddy:EditRange(index, minRoll, maxRoll, multiplier)
        return
    end

    if cmd == "remove" then
        local index = tonumber(args[2])

        if not index then
            RollBuddy:Print("Usage: /rb remove <index>")
            return
        end

        RollBuddy:RemoveRange(index)
        return
    end

    if cmd == "debugdb" then
        RollBuddy:Print("DB table: " .. tostring(RollBuddy.db))
        RollBuddy:Print("rollRanges table: " .. tostring(RollBuddy.db.rollRanges))
        RollBuddy:Print("Range count: " .. tostring(RollBuddy.db.rollRanges and #self.db.rollRanges or 0))
        return
    end

    RollBuddy:Print("Commands:")
    RollBuddy:Print("/rb - toggle main window")
    RollBuddy:Print("/rb settings - toggle settings window")
    RollBuddy:Print("/rb list")
    RollBuddy:Print("/rb add <min> <max> <multiplier>")
    RollBuddy:Print("/rb edit <index> <min> <max> <multiplier>")
    RollBuddy:Print("/rb remove <index>")
end

RollBuddy:Print("Loaded: " .. tostring(RollBuddy.addonName))

RollBuddy:Print("DB table: " .. tostring(RollBuddy.db))
RollBuddy:Print("Range count: " .. tostring(RollBuddy.db.rollRanges and #RollBuddy.db.rollRanges or 0))