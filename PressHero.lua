-- PressHero: Minimal Heroism Alert Addon
local prefix = "PH_REQUEST_HERO"

-- Returns the correct icon and label for the player's class/spec/faction
local function GetHeroIconAndLabel()
    local _, class = UnitClass("player")
    class = string.upper(class or "")
    if class == "SHAMAN" then
        local faction = UnitFactionGroup("player")
        if faction == "Alliance" then
            return "Interface\\Icons\\Ability_Shaman_Heroism", "Heroism"
        else
            return "Interface\\Icons\\Spell_Nature_BloodLust", "Bloodlust"
        end
    elseif class == "MAGE" then
        return "Interface\\Icons\\ability_mage_timewarp", "Time Warp"
    elseif class == "EVOKER" then
        return "Interface\\Icons\\ability_evoker_furyoftheaspects", "Fury of the Aspects"
    elseif class == "HUNTER" then
        local spec = GetSpecialization()
        local specID = spec and select(1, GetSpecializationInfo(spec))
        if specID == 254 then
            return "Interface\\Icons\\inv_111_hunter_ability_harrierscall", "Harrier's Cry"
        else
            return "Interface\\Icons\\spell_shadow_unholyfrenzy", "Primal Rage"
        end
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
    ShowCustomHeroAlert()
    PlaySound(8959, "Master")
end

-- Slash command: /presshero
SLASH_PRESSHERO1 = "/presshero"
SlashCmdList["PRESSHERO"] = function()
    print("|cff00ffff[Press Hero]|r |cff00ff00You can press hero!|r")
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
    local icon, label = GetHeroIconAndLabel()
    print("|cff00ffff[Press Hero]|r Debug: Hero spell:", label)
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