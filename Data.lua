RollBuddy.round = {
    players = {},
    rolls = {},
    winner = nil,
}

RollBuddy.db.rollRanges = RollBuddy.db.rollRanges or {
    { min = 1,   max = 40,  multiplier = 0 },
    { min = 41,  max = 50,  multiplier = 1 },
    { min = 51,  max = 80,  multiplier = 2 },
    { min = 81,  max = 99,  multiplier = 3 },
    { min = 100, max = 100, multiplier = 4 },
}

function RollBuddy:ResetRound()
    self.round.players = {}
    self.round.rolls = {}
    self.round.winner = nil
    self:Print("Round reset")
end

function RollBuddy:ListRanges()
    if not self.db.rollRanges or #self.db.rollRanges == 0 then
        self:Print("No ranges configured.")
        return
    end

    self:Print("Configured ranges:")
    for i, range in ipairs(self.db.rollRanges) do
        self:Print(i .. ". " .. range.min .. "-" .. range.max .. " => " .. range.multiplier .. "x")
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