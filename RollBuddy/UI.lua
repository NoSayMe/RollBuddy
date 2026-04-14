local unpackFn = unpack or table.unpack

local function createBaseFrame(name, title, width, height, point)
    local frame = CreateFrame("Frame", name, UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(width, height)
    frame:SetPoint(unpackFn(point))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 8, 0)
    frame.title:SetText(title)

    return frame
end

function RollBuddy:CreateMainWindow()
    if self.frame then
        return
    end

    local frame = createBaseFrame("RollBuddyMainFrame", "RollBuddy", 320, 220, { "CENTER" })

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("TOPLEFT", 20, -40)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetWidth(280)
    frame.text:SetJustifyV("TOP")

    frame.resetButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.resetButton:SetSize(120, 30)
    frame.resetButton:SetPoint("BOTTOM", 0, 20)
    frame.resetButton:SetText("Reset")
    frame.resetButton:SetScript("OnClick", function()
        self:ResetRound()
    end)

    frame.settingsButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.settingsButton:SetSize(120, 30)
    frame.settingsButton:SetPoint("BOTTOM", 0, 55)
    frame.settingsButton:SetText("Settings")
    frame.settingsButton:SetScript("OnClick", function()
        self:ToggleSettingsWindow()
    end)

    self.frame = frame
    self:RefreshMainWindow()
end

function RollBuddy:RefreshMainWindow()
    if not self.frame then
        return
    end

    local lines = { "Current round rolls:" }
    local playerNames = {}
    for playerName in pairs(self.round.rolls) do
        playerNames[#playerNames + 1] = playerName
    end
    table.sort(playerNames)

    for _, playerName in ipairs(playerNames) do
        local rollData = self.round.rolls[playerName]
        lines[#lines + 1] = playerName .. ": " .. rollData.value .. " (" .. rollData.min .. "-" .. rollData.max .. ")"
    end

    if #playerNames == 0 then
        lines[#lines + 1] = "No rolls yet. Ask players to /roll."
    end

    self.frame.text:SetText(table.concat(lines, "\n"))
end

function RollBuddy:ToggleWindow()
    if not self.frame then
        self:CreateMainWindow()
    end

    if self.frame:IsShown() then
        self.frame:Hide()
        self:Print("Window hidden")
    else
        self.frame:Show()
        self:RefreshMainWindow()
        self:Print("Window shown")
    end
end

function RollBuddy:CreateSettingsWindow()
    if self.settingsFrame then
        return
    end

    local frame = createBaseFrame(
        "RollBuddySettingsFrame",
        "RollBuddy Settings",
        360,
        260,
        { "CENTER", UIParent, "CENTER", 40, -40 }
    )

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("TOPLEFT", 20, -40)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")
    frame.text:SetWidth(300)

    self.settingsFrame = frame
    self:RefreshSettingsWindow()
end

function RollBuddy:RefreshSettingsWindow()
    if not self.settingsFrame then
        return
    end

    self.settingsFrame.text:SetText(table.concat(self:GetFormattedRanges(), "\n"))
end

function RollBuddy:ToggleSettingsWindow()
    if not self.settingsFrame then
        self:CreateSettingsWindow()
    end

    if self.settingsFrame:IsShown() then
        self.settingsFrame:Hide()
        self:Print("Settings hidden")
    else
        self:RefreshSettingsWindow()
        self.settingsFrame:Show()
        self:Print("Settings shown")
    end
end
