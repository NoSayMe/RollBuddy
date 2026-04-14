local function formatRange(range)
    return range.min .. "-" .. range.max .. " => " .. range.multiplier .. "x"
end

function RollBuddy:ResetRound()
    self.round.players = {}
    self.round.rolls = {}
    self.round.winner = nil

    if IsInGroup() then
        local channel = IsInRaid() and "RAID" or "PARTY"
        SendChatMessage("RollBuddy round reset.", channel)
    end

    if self.RefreshMainWindow then
        self:RefreshMainWindow()
    end

    self:Print("Round reset")
end

function RollBuddy:AddRollFromChat(playerName, rollValue, minRoll, maxRoll)
    if not playerName or not rollValue then
        return
    end

    self.round.players[playerName] = true
    self.round.rolls[playerName] = {
        value = rollValue,
        min = minRoll,
        max = maxRoll,
    }

    if self.RefreshMainWindow then
        self:RefreshMainWindow()
    end
end

function RollBuddy:ListRanges()
    if #self.db.rollRanges == 0 then
        self:Print("No ranges configured.")
        return
    end

    self:Print("Configured ranges:")
    for i, range in ipairs(self.db.rollRanges) do
        self:Print(i .. ". " .. formatRange(range))
    end
end

function RollBuddy:AddRange(minRoll, maxRoll, multiplier)
    table.insert(self.db.rollRanges, {
        min = minRoll,
        max = maxRoll,
        multiplier = multiplier,
    })

    self:Print("Added range: " .. minRoll .. "-" .. maxRoll .. " => " .. multiplier .. "x")

    if self.RefreshSettingsWindow then
        self:RefreshSettingsWindow()
    end
end

function RollBuddy:EditRange(index, minRoll, maxRoll, multiplier)
    local range = self.db.rollRanges[index]
    if not range then
        self:Print("Invalid range index: " .. tostring(index))
        return
    end

    range.min = minRoll
    range.max = maxRoll
    range.multiplier = multiplier

    self:Print("Edited range #" .. index .. ": " .. minRoll .. "-" .. maxRoll .. " => " .. multiplier .. "x")

    if self.RefreshSettingsWindow then
        self:RefreshSettingsWindow()
    end
end

function RollBuddy:RemoveRange(index)
    if not self.db.rollRanges[index] then
        self:Print("Invalid range index: " .. tostring(index))
        return
    end

    table.remove(self.db.rollRanges, index)

    self:Print("Removed range #" .. index)

    if self.RefreshSettingsWindow then
        self:RefreshSettingsWindow()
    end
end

function RollBuddy:GetFormattedRanges()
    local lines = { "Roll ranges:" }

    for i, range in ipairs(self.db.rollRanges) do
        lines[#lines + 1] = i .. ". " .. formatRange(range)
    end

    return lines
end
