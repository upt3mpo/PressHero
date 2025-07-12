local addonName = ...
local prefix = "PH_REQUEST_HERO"

local function InitializePressHero()
    -- Register addon message channel
    C_ChatInfo.RegisterAddonMessagePrefix(prefix)

    -- Heroism-type spells (expandable)
    local HERO_SPELLS = {
        [32182] = "Shaman: Heroism",
        [2825]  = "Shaman: Bloodlust",
        [80353] = "Mage: Time Warp",
        [264667] = "Hunter: Primal Rage",
        [390386] = "Evoker: Fury of the Aspects",
    }

    -- Minimal: Only check if player has the spell
    local function CanPressHero()
        for spellID, spellName in pairs(HERO_SPELLS) do
            if IsPlayerSpell(spellID) then
                return true, spellID, spellName
            end
        end
        return false, nil, nil
    end

    -- Minimal debug function
    function DebugHeroSpells()
        print("|cff00ffff[Press Hero]|r [DEBUG] DebugHeroSpells function called!")
        print("|cff00ffff[Press Hero]|r === HERO SPELL DEBUG ===")
        for spellID, spellName in pairs(HERO_SPELLS) do
            local hasSpell = IsPlayerSpell(spellID)
            print(string.format("|cff00ffff[Press Hero]|r %s (ID: %d):", spellName, spellID))
            print(string.format("  - Has spell: %s", hasSpell and "YES" or "NO"))
        end
        print("|cff00ffff[Press Hero]|r === END DEBUG ===")
    end

    -- Get player's class color
    local function GetPlayerClassColor(playerName)
        local _, class = UnitClass(playerName)
        if class then
            local color = RAID_CLASS_COLORS[class]
            return color.r, color.g, color.b
        end
        return 1, 1, 1 -- Default white
    end

    -- Utility: Get spell icon
    local function GetHeroSpellIcon(spellID)
        local icon = nil
        if spellID then
            icon = select(3, GetSpellInfo(spellID))
        end
        return icon or 134400 -- Default: Ability_Shaman_Heroism
    end

    -- Custom alert frame
    local function ShowCustomHeroAlert(spellID)
        if not PressHeroAlertFrame then
            PressHeroAlertFrame = CreateFrame("Frame", "PressHeroAlertFrame", UIParent, "BackdropTemplate")
            PressHeroAlertFrame:SetSize(350, 120)
            PressHeroAlertFrame:SetPoint("CENTER")
            PressHeroAlertFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = nil, tile = true, tileSize = 16, edgeSize = 16})
            PressHeroAlertFrame:SetBackdropColor(0, 0, 0, 0.7)
            -- Icon
            PressHeroAlertFrame.icon = PressHeroAlertFrame:CreateTexture(nil, "ARTWORK")
            PressHeroAlertFrame.icon:SetSize(64, 64)
            PressHeroAlertFrame.icon:SetPoint("LEFT", 20, 0)
            -- Text
            PressHeroAlertFrame.text = PressHeroAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
            PressHeroAlertFrame.text:SetPoint("LEFT", PressHeroAlertFrame.icon, "RIGHT", 20, 0)
            PressHeroAlertFrame.text:SetJustifyH("LEFT")
            PressHeroAlertFrame.text:SetJustifyV("MIDDLE")
        end
        local icon = GetHeroSpellIcon(spellID)
        PressHeroAlertFrame.icon:SetTexture(icon)
        PressHeroAlertFrame.text:SetText("|cffff2222PRESS IT!|r")
        PressHeroAlertFrame:Show()
        C_Timer.After(2.5, function() PressHeroAlertFrame:Hide() end)
    end

    -- On message received (update to show custom alert)
    local function OnAddonMessage(prefix, msg, channel, sender)
        if prefix ~= "PH_REQUEST_HERO" then return end
        print(string.format("|cff00ffff[Press Hero]|r Received request from %s", sender))
        local canPress, spellID, spellName = CanPressHero()
        if canPress then
            local r, g, b = GetPlayerClassColor(sender)
            local coloredSender = string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, sender)
            local alertChannel = IsInRaid() and "RAID_WARNING" or "PARTY"
            SendChatMessage(string.format("PRESS HERO NOW! (%s requested)", coloredSender), alertChannel)
            PlaySound(8959, "Master")
            RaidNotice_AddMessage(RaidWarningFrame, "PRESS HERO NOW!", ChatTypeInfo["RAID_WARNING"])
            print(string.format("|cff00ffff[Press Hero]|r |cff00ff00PRESS IT!|r (%s requested by %s)", spellName, coloredSender))
            ShowCustomHeroAlert(spellID)
            if not UnitIsDeadOrGhost("player") then
                UIFrameFlash(WorldFrame, 0.5, 0.5, 1, false, 0, 0)
            end
        else
            print("|cff00ffff[Press Hero]|r |cffff0000Cannot press hero:|r No hero spells available")
        end
    end

    -- Slash command & keybind trigger
    SLASH_PRESSHERO1 = "/presshero"
    SLASH_PRESSHERO2 = "/hero"
    SLASH_PRESSHERO3 = "/lust"
    SlashCmdList["PRESSHERO"] = function(msg)
        if not IsInGroup() then
            print("|cff00ffff[Press Hero]|r |cffff0000You're not in a group.|r")
            return
        end
        local canPress, spellID, spellName = CanPressHero()
        if canPress then
            print(string.format("|cff00ffff[Press Hero]|r |cff00ff00You can press hero!|r (%s)", spellName))
        end
        local channel = IsInRaid() and "RAID" or "PARTY"
        C_ChatInfo.SendAddonMessage(prefix, "REQ", channel)
        local r, g, b = GetPlayerClassColor(UnitName("player"))
        local coloredName = string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, UnitName("player"))
        print(string.format("|cff00ffff[Press Hero]|r Request sent to group by %s.", coloredName))
    end

    -- Event handler
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_ADDON")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "CHAT_MSG_ADDON" then
            local prefix, msg, channel, sender = ...
            OnAddonMessage(prefix, msg, channel, sender)
        end
    end)

    -- Minimal status check command
    local function CheckHeroStatus()
        local canPress, spellID, spellName = CanPressHero()
        if canPress then
            print(string.format("|cff00ffff[Press Hero]|r |cff00ff00%s is available!|r", spellName))
        else
            print("|cff00ffff[Press Hero]|r |cffff0000No hero spells available|r")
        end
    end
    SLASH_PRESSHEROSTATUS1 = "/herostatus"
    SlashCmdList["PRESSHEROSTATUS"] = CheckHeroStatus

    SLASH_PRESSHERODEBUG1 = "/herodebug"
    SlashCmdList["PRESSHERODEBUG"] = function()
        print("|cff00ffff[Press Hero]|r Debug: Addon loaded successfully")
        print("|cff00ffff[Press Hero]|r Debug: In group:", IsInGroup())
        print("|cff00ffff[Press Hero]|r Debug: In raid:", IsInRaid())
        local canPress, spellID, spellName = CanPressHero()
        print("|cff00ffff[Press Hero]|r Debug: Can press hero:", canPress)
        if canPress then
            print("|cff00ffff[Press Hero]|r Debug: Available spell:", spellName)
        end
        DebugHeroSpells()
        print("|cff00ffff[Press Hero]|r [DEBUG] DebugHeroSpells should have run above.")
    end
    SLASH_HEROTESTRECV1 = "/herotestrecv"
    SlashCmdList["HEROTESTRECV"] = function()
        print("|cff00ffff[Press Hero]|r [DEBUG] Simulating incoming /presshero request from DebugUser...")
        OnAddonMessage(prefix, "REQ", "PARTY", "DebugUser")
    end
    BINDING_NAME_PRESSHERO = "Press Hero: Request Heroism/Bloodlust/Time Warp"
end

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitializePressHero()
    end
end)
