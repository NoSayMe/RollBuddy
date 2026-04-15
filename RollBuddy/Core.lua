local addonName = ...

RollBuddyDB = RollBuddyDB or {}

RollBuddy = RollBuddy or {}
RollBuddy.addonName = addonName
RollBuddy.db = RollBuddyDB
RollBuddy.frame = nil
RollBuddy.settingsFrame = nil
RollBuddy.eventFrame = nil

local DEFAULT_ROLL_RANGES = {
    { min = 1,   max = 40,  multiplier = 0 },
    { min = 41,  max = 50,  multiplier = 1 },
    { min = 51,  max = 80,  multiplier = 2 },
    { min = 81,  max = 99,  multiplier = 3 },
    { min = 100, max = 100, multiplier = 4 },
}

local DEFAULT_START_CONFIG = {
    message = "RollBuddy game started! Roll now with /roll 1-100.",
    say = true,
    general = false,
}

local function copyRanges(ranges)
    local copied = {}

    for i, range in ipairs(ranges) do
        copied[i] = {
            min = range.min,
            max = range.max,
            multiplier = range.multiplier,
        }
    end

    return copied
end

function RollBuddy:InitializeDatabase()
    self.db.rollRanges = self.db.rollRanges or copyRanges(DEFAULT_ROLL_RANGES)
    self.db.startConfig = self.db.startConfig or {}
    self.db.startConfig.message = self.db.startConfig.message or DEFAULT_START_CONFIG.message
    if self.db.startConfig.say == nil then
        self.db.startConfig.say = DEFAULT_START_CONFIG.say
    end
    if self.db.startConfig.general == nil then
        self.db.startConfig.general = DEFAULT_START_CONFIG.general
    end
end

function RollBuddy:InitializeRuntimeState()
    self.round = {
        players = {},
        rolls = {},
        winner = nil,
    }
end

function RollBuddy:Initialize()
    self:InitializeDatabase()
    self:InitializeRuntimeState()
    self:RegisterEvents()

    self:Print("Loaded: " .. tostring(self.addonName))
    self:Print("Range count: " .. tostring(#self.db.rollRanges))
end

function RollBuddy:RegisterEvents()
    if self.eventFrame then
        return
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_SYSTEM")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_SYSTEM" then
            local message = ...
            self:HandleSystemMessage(message)
        end
    end)

    self.eventFrame = frame
end

function RollBuddy:HandleSystemMessage(message)
    if not message then
        return
    end

    local playerName, rollValue, minRoll, maxRoll = string.match(message, "^(.-) rolls (%d+) %((%d+)%-(%d+)%)$")
    if not playerName then
        return
    end

    self:AddRollFromChat(playerName, tonumber(rollValue), tonumber(minRoll), tonumber(maxRoll))
end

RollBuddy:Initialize()
