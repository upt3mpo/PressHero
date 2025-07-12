-- PressHero: Minimal Heroism Alert Addon
local prefix = "PH_REQUEST_HERO"

-- List of all heroism-type spells to check for
local HERO_SPELLS = {
    [32182] = "Shaman: Heroism",
    [2825]  = "Shaman: Bloodlust",
    [80353] = "Mage: Time Warp",
    [264667] = "Hunter: Primal Rage",
    [466904] = "Hunter: Harrier's Cry",
    [390386] = "Evoker: Fury of the Aspects",
}

-- Icon and label logic for each class
local HERO_ICONS = {
    SHAMAN = { icon = "Interface\\Icons\\Ability_Shaman_Heroism", label = "Heroism" },
    MAGE = { icon = "Interface\\Icons\\Spell_Arcane_TemporalShift", label = "Time Warp" },
    HUNTER = function()
        local spec = GetSpecialization()
        local specID = spec and select(1, GetSpecializationInfo(spec))
        -- Marksmanship specID is 254
        if specID == 254 and IsPlayerSpell(466904) then
            return "Interface\\Icons\\ability_hunter_harrierscry", "Harrier's Cry"
        elseif IsPlayerSpell(264667) then
            return "Interface\\Icons\\Ability_Hunter_PrimalRage", "Primal Rage"
        else
            return "Interface\\Icons\\Ability_Hunter_PrimalRage", "Primal Rage"
        end
    end,
    EVOKER = { icon = "Interface\\Icons\\ability_evoker_furyoftheaspects", label = "Fury of the Aspects" },
}

-- Returns true, spellID, spellName if player can press hero (has any hero spell)
local function CanPressHero()
    for spellID, spellName in pairs(HERO_SPELLS) do
        if IsPlayerSpell(spellID) then
            return true, spellID, spellName
        end
    end
    return false, nil, nil
end

-- Returns the correct icon and label for the player's class/spec/spell
local function GetHeroIconAndLabel()
    local _, class = UnitClass("player")
    class = string.upper(class or "")
    local entry = HERO_ICONS[class]
    if type(entry) == "function" then
        return entry()
    elseif entry then
        return entry.icon, entry.label
    else
        return "Interface\\Icons\\Ability_Shaman_Heroism", "Heroism"
    end
end

-- Shows the big alert with icon and label
local function ShowCustomHeroAlert()
    if not PressHeroAlertFrame then
        PressHeroAlertFrame = CreateFrame("Frame", "PressHeroAlertFrame", UIParent, "BackdropTemplate")
        PressHeroAlertFrame:SetSize(1200, 450)
        PressHeroAlertFrame:SetPoint("CENTER")
        PressHeroAlertFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
        PressHeroAlertFrame:SetBackdropColor(0, 0, 0, 0.9)
        PressHeroAlertFrame.icon = PressHeroAlertFrame:CreateTexture(nil, "ARTWORK")
        PressHeroAlertFrame.icon:SetSize(320, 320)
        PressHeroAlertFrame.icon:SetPoint("LEFT", 100, 0)
        PressHeroAlertFrame.text = PressHeroAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
        PressHeroAlertFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 180, "OUTLINE, THICKOUTLINE")
        PressHeroAlertFrame.text:SetPoint("LEFT", PressHeroAlertFrame.icon, "RIGHT", 100, 0)
        PressHeroAlertFrame.text:SetJustifyH("LEFT")
        PressHeroAlertFrame.text:SetJustifyV("MIDDLE")
        PressHeroAlertFrame.spellLabel = PressHeroAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        PressHeroAlertFrame.spellLabel:SetFont("Fonts\\FRIZQT__.TTF", 48, "OUTLINE")
        PressHeroAlertFrame.spellLabel:SetPoint("TOP", PressHeroAlertFrame.icon, "BOTTOM", 0, -10)
        PressHeroAlertFrame.spellLabel:SetJustifyH("CENTER")
    end
    local icon, label = GetHeroIconAndLabel()
    PressHeroAlertFrame.icon:SetTexture(icon)
    PressHeroAlertFrame.text:SetText("|cffff2222PRESS IT!|r")
    PressHeroAlertFrame.spellLabel:SetText("(" .. label .. ")")
    PressHeroAlertFrame:Show()
    C_Timer.After(2.5, function() PressHeroAlertFrame:Hide() end)
end

-- Handles incoming addon messages
local function OnAddonMessage(prefix, msg, channel, sender)
    if prefix ~= "PH_REQUEST_HERO" then return end
    local canPress = CanPressHero()
    if canPress then
        ShowCustomHeroAlert()
        PlaySound(8959, "Master")
    end
end

-- Slash command: /presshero
SLASH_PRESSHERO1 = "/presshero"
SlashCmdList["PRESSHERO"] = function()
    local canPress, spellID, spellName = CanPressHero()
    if canPress then
        print("|cff00ffff[Press Hero]|r |cff00ff00You can press hero!|r (" .. spellName .. ")")
    end
    local channel = IsInRaid() and "RAID" or "PARTY"
    C_ChatInfo.SendAddonMessage(prefix, "REQ", channel)
    local alertChannel = IsInRaid() and "RAID_WARNING" or "PARTY"
    SendChatMessage("PRESS HERO!", alertChannel)
end

-- Debug: Simulate receiving a hero request
SLASH_HEROTESTRECV1 = "/herotestrecv"
SlashCmdList["HEROTESTRECV"] = function()
    OnAddonMessage(prefix, "REQ", "PARTY", "DebugUser")
end

-- Debug: Show hero spell detection
SLASH_PRESSHERODEBUG1 = "/herodebug"
SlashCmdList["PRESSHERODEBUG"] = function()
    print("|cff00ffff[Press Hero]|r Debug: Addon loaded successfully")
    local canPress, spellID, spellName = CanPressHero()
    print("|cff00ffff[Press Hero]|r Debug: Can press hero:", canPress)
    if canPress then
        print("|cff00ffff[Press Hero]|r Debug: Available spell:", spellName)
    end
end

-- Listen for addon messages
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg, channel, sender = ...
        OnAddonMessage(prefix, msg, channel, sender)
    end
end)

-- Initialize after login
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- All logic is already loaded, nothing else needed
    end
end)
