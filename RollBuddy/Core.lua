local addonName = ...

RollBuddyDB = RollBuddyDB or {}

RollBuddy = RollBuddy or {}
RollBuddy.addonName = addonName
RollBuddy.db = RollBuddyDB
RollBuddy.frame = nil
RollBuddy.settingsFrame = nil

local DEFAULT_ROLL_RANGES = {
    { min = 1,   max = 40,  multiplier = 0 },
    { min = 41,  max = 50,  multiplier = 1 },
    { min = 51,  max = 80,  multiplier = 2 },
    { min = 81,  max = 99,  multiplier = 3 },
    { min = 100, max = 100, multiplier = 4 },
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

    self:Print("Loaded: " .. tostring(self.addonName))
    self:Print("Range count: " .. tostring(#self.db.rollRanges))
end

RollBuddy:Initialize()
