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

    local frame = createBaseFrame("RollBuddyMainFrame", "RollBuddy", 320, 260, { "CENTER" })

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

    frame.startButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.startButton:SetSize(120, 30)
    frame.startButton:SetPoint("BOTTOM", 0, 90)
    frame.startButton:SetText("Start")
    frame.startButton:SetScript("OnClick", function()
        self:StartRound()
    end)

    frame.statisticsButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.statisticsButton:SetSize(120, 30)
    frame.statisticsButton:SetPoint("BOTTOM", 0, 125)
    frame.statisticsButton:SetText("Statistics")
    frame.statisticsButton:SetScript("OnClick", function()
        self:ToggleStatisticsWindow()
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
        380,
        330,
        { "CENTER", UIParent, "CENTER", 40, -40 }
    )

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("TOPLEFT", 20, -40)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")
    frame.text:SetWidth(340)

    frame.sayToggleButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.sayToggleButton:SetSize(160, 26)
    frame.sayToggleButton:SetPoint("BOTTOMLEFT", 20, 55)
    frame.sayToggleButton:SetScript("OnClick", function()
        self:SetStartChannelEnabled("say", not self.db.startConfig.say)
    end)

    frame.generalToggleButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.generalToggleButton:SetSize(160, 26)
    frame.generalToggleButton:SetPoint("BOTTOMRIGHT", -20, 55)
    frame.generalToggleButton:SetScript("OnClick", function()
        self:SetStartChannelEnabled("general", not self.db.startConfig.general)
    end)

    frame.startTextButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.startTextButton:SetSize(220, 26)
    frame.startTextButton:SetPoint("BOTTOM", 0, 20)
    frame.startTextButton:SetText("Set start message")
    frame.startTextButton:SetScript("OnClick", function()
        if not StaticPopupDialogs["ROLLBUDDY_SET_START_MESSAGE"] then
            StaticPopupDialogs["ROLLBUDDY_SET_START_MESSAGE"] = {
                text = "Enter start message",
                button1 = "Save",
                button2 = "Cancel",
                hasEditBox = 1,
                maxLetters = 255,
                OnAccept = function(popupFrame)
                    local value = popupFrame.editBox:GetText()
                    self:SetStartMessage(value)
                end,
                EditBoxOnEnterPressed = function(editBox)
                    local parent = editBox:GetParent()
                    local value = editBox:GetText()
                    self:SetStartMessage(value)
                    parent:Hide()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
        end

        local dialog = StaticPopup_Show("ROLLBUDDY_SET_START_MESSAGE")
        if dialog and dialog.editBox then
            dialog.editBox:SetText(self:GetStartMessage())
            dialog.editBox:HighlightText()
            dialog.editBox:SetFocus()
        end
    end)

    self.settingsFrame = frame
    self:RefreshSettingsWindow()
end

function RollBuddy:RefreshSettingsWindow()
    if not self.settingsFrame then
        return
    end

    local lines = self:GetFormattedRanges()
    lines[#lines + 1] = ""
    local startSettingsLines = self:GetFormattedStartSettings()
    for _, line in ipairs(startSettingsLines) do
        lines[#lines + 1] = line
    end
    self.settingsFrame.text:SetText(table.concat(lines, "\n"))

    self.settingsFrame.sayToggleButton:SetText("Toggle /y: " .. (self.db.startConfig.say and "ON" or "OFF"))
    self.settingsFrame.generalToggleButton:SetText("Toggle /1: " .. (self.db.startConfig.general and "ON" or "OFF"))
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

function RollBuddy:CreateStatisticsWindow()
    if self.statisticsFrame then
        return
    end

    local frame = createBaseFrame(
        "RollBuddyStatisticsFrame",
        "RollBuddy Statistics",
        420,
        320,
        { "CENTER", UIParent, "CENTER", -40, -40 }
    )

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("TOPLEFT", 20, -40)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")
    frame.text:SetWidth(380)

    frame.resetButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.resetButton:SetSize(160, 28)
    frame.resetButton:SetPoint("BOTTOM", 0, 20)
    frame.resetButton:SetText("Reset statistics")
    frame.resetButton:SetScript("OnClick", function()
        self:ResetStatistics()
    end)

    self.statisticsFrame = frame
    self:RefreshStatisticsWindow()
end

function RollBuddy:RefreshStatisticsWindow()
    if not self.statisticsFrame then
        return
    end

    local lines = self:GetStatisticsLines()
    self.statisticsFrame.text:SetText(table.concat(lines, "\n"))
end

function RollBuddy:ToggleStatisticsWindow()
    if not self.statisticsFrame then
        self:CreateStatisticsWindow()
    end

    if self.statisticsFrame:IsShown() then
        self.statisticsFrame:Hide()
        self:Print("Statistics hidden")
    else
        self:RefreshStatisticsWindow()
        self.statisticsFrame:Show()
        self:Print("Statistics shown")
    end
end
