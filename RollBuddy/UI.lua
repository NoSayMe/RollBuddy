function RollBuddy:CreateMainWindow()
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame", "RollBuddyMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(320, 220)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 8, 0)
    frame.title:SetText("RollBuddy")

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("TOPLEFT", 20, -40)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetText("Hello world window\n\nThis will become our roll game UI.")

    frame.resetButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.resetButton:SetSize(120, 30)
    frame.resetButton:SetPoint("BOTTOM", 0, 20)
    frame.resetButton:SetText("Reset")
    frame.resetButton:SetScript("OnClick", function()
        RollBuddy:ResetRound()
    end)

    frame.settingsButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.settingsButton:SetSize(120, 30)
    frame.settingsButton:SetPoint("BOTTOM", 0, 55)
    frame.settingsButton:SetText("Settings")

    frame.settingsButton:SetScript("OnClick", function()
        RollBuddy:ToggleSettingsWindow()
    end)

    self.frame = frame
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
        self:Print("Window shown")
    end
end

function RollBuddy:CreateSettingsWindow()
    if self.settingsFrame then
        return
    end

    local frame = CreateFrame("Frame", "RollBuddySettingsFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(360, 260)
    frame:SetPoint("CENTER", UIParent, "CENTER", 40, -40)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 8, 0)
    frame.title:SetText("RollBuddy Settings")

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

    local lines = { "Roll ranges:" }

    for i, range in ipairs(self.db.rollRanges) do
        lines[#lines + 1] = i .. ". " .. range.min .. "-" .. range.max .. " => " .. range.multiplier .. "x"
    end

    self.settingsFrame.text:SetText(table.concat(lines, "\n"))
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

