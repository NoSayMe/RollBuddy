local function formatRange(range)
    return range.min .. "-" .. range.max .. " => " .. range.multiplier .. "x"
end

function RollBuddy:GetStartMessage()
    return self.db.startConfig.message
end

function RollBuddy:SetStartMessage(message)
    local trimmed = string.match(message or "", "^%s*(.-)%s*$")
    if not trimmed or trimmed == "" then
        self:Print("Start message cannot be empty.")
        return
    end

    self.db.startConfig.message = trimmed
    self:Print("Start message updated.")

    if self.RefreshSettingsWindow then
        self:RefreshSettingsWindow()
    end
end

function RollBuddy:SetStartChannelEnabled(channel, enabled)
    if channel ~= "say" and channel ~= "general" then
        self:Print("Unsupported channel: " .. tostring(channel))
        return
    end

    self.db.startConfig[channel] = enabled and true or false
    self:Print("Start output " .. channel .. " set to " .. tostring(self.db.startConfig[channel]))

    if self.RefreshSettingsWindow then
        self:RefreshSettingsWindow()
    end
end

local function getEnabledChannels(startConfig)
    local channels = {}
    if startConfig.say then
        channels[#channels + 1] = "/y"
    end
    if startConfig.general then
        channels[#channels + 1] = "/1"
    end
    return channels
end

function RollBuddy:GetFormattedStartSettings()
    local channels = getEnabledChannels(self.db.startConfig)
    local formattedChannels = #channels > 0 and table.concat(channels, ", ") or "none"

    return {
        "Start message:",
        self.db.startConfig.message,
        "Channels: " .. formattedChannels,
    }
end

function RollBuddy:StartRound()
    local message = self:GetStartMessage()
    local sent = 0

    if self.db.startConfig.say then
        SendChatMessage(message, "SAY")
        sent = sent + 1
    end

    if self.db.startConfig.general then
        if GetChannelName(1) and GetChannelName(1) > 0 then
            SendChatMessage(message, "CHANNEL", nil, 1)
            sent = sent + 1
        else
            self:Print("General channel (/1) is not available here.")
        end
    end

    if sent == 0 then
        self:Print("No start output channels enabled. Configure them in settings.")
        return
    end

    self:Print("Start message sent.")
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

local function sortPlayerNames(players)
    local names = {}
    for playerName in pairs(players) do
        names[#names + 1] = playerName
    end
    table.sort(names)
    return names
end

function RollBuddy:GetStatisticsLines()
    local lines = {
        "Player statistics (skeleton):",
        "Player | Games | Wins | Total",
    }

    local players = self.db.statistics.players or {}
    local playerNames = sortPlayerNames(players)

    if #playerNames == 0 then
        lines[#lines + 1] = "No players tracked yet."
        return lines
    end

    for _, playerName in ipairs(playerNames) do
        local stats = players[playerName]
        local games = tonumber(stats.games) or 0
        local wins = tonumber(stats.wins) or 0
        local totalValue = tonumber(stats.totalValue) or 0
        lines[#lines + 1] = playerName .. " | " .. games .. " | " .. wins .. " | " .. totalValue
    end

    return lines
end

function RollBuddy:ResetStatistics()
    self.db.statistics.players = {}

    if self.RefreshStatisticsWindow then
        self:RefreshStatisticsWindow()
    end

    self:Print("Statistics reset")
end
