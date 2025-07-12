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

    -- Check if player has any Lust spell ready
    local function CanPressHero()
        if type(GetSpellCooldown) ~= "function" then
            print("|cff00ffff[Press Hero]|r ERROR: GetSpellCooldown is not available in this environment!")
            return false, nil, nil
        end
        for spellID, spellName in pairs(HERO_SPELLS) do
            if IsPlayerSpell(spellID) then
                local start, duration, enabled = GetSpellCooldown(spellID)
                local ready = (enabled == 1 and (start + duration - GetTime()) <= 0)
                
                -- Check for hero debuffs based on spell type
                local hasDebuff = false
                if spellID == 32182 or spellID == 2825 then
                    -- Shaman spells - check for Sated
                    hasDebuff = AuraUtil.FindAuraByName("Sated", "player", "HARMFUL")
                elseif spellID == 80353 or spellID == 390386 then
                    -- Mage Time Warp and Evoker Fury - check for Temporal Displacement
                    hasDebuff = AuraUtil.FindAuraByName("Temporal Displacement", "player", "HARMFUL")
                elseif spellID == 264667 then
                    -- Hunter Primal Rage - check for Exhaustion
                    hasDebuff = AuraUtil.FindAuraByName("Exhaustion", "player", "HARMFUL")
                end
                
                if ready and not hasDebuff then
                    return true, spellID, spellName
                end
            end
        end
        return false, nil, nil
    end

    -- Enhanced debug function to check all hero spells
    function DebugHeroSpells()
        if type(GetSpellCooldown) ~= "function" then
            print("|cff00ffff[Press Hero]|r ERROR: GetSpellCooldown is not available in this environment!")
            return
        end
        print("|cff00ffff[Press Hero]|r [DEBUG] DebugHeroSpells function called!")
        print("|cff00ffff[Press Hero]|r === HERO SPELL DEBUG ===")
        for spellID, spellName in pairs(HERO_SPELLS) do
            local hasSpell = IsPlayerSpell(spellID)
            local start, duration, enabled = GetSpellCooldown(spellID)
            local ready = (enabled == 1 and (start + duration - GetTime()) <= 0)
            
            print(string.format("|cff00ffff[Press Hero]|r %s (ID: %d):", spellName, spellID))
            print(string.format("  - Has spell: %s", hasSpell and "YES" or "NO"))
            if hasSpell then
                print(string.format("  - Enabled: %s", enabled == 1 and "YES" or "NO"))
                print(string.format("  - Cooldown: %.1f seconds", math.max(0, start + duration - GetTime())))
                print(string.format("  - Ready: %s", ready and "YES" or "NO"))
            end
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

    -- On message received
    local function OnAddonMessage(prefix, msg, channel, sender)
        if prefix ~= "PH_REQUEST_HERO" then return end
        
        print(string.format("|cff00ffff[Press Hero]|r Received request from %s", sender))
        
        local canPress, spellID, spellName = CanPressHero()
        
        if canPress then
            -- Enhanced alert with more information
            local r, g, b = GetPlayerClassColor(sender)
            local coloredSender = string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, sender)
            
            -- Send to raid warning if in raid, otherwise to party
            local alertChannel = IsInRaid() and "RAID_WARNING" or "PARTY"
            SendChatMessage(string.format("PRESS HERO NOW! (%s requested)", coloredSender), alertChannel)
            
            -- Play sound and show UI alert
            PlaySound(8959, "Master") -- Raid warning sound
            RaidNotice_AddMessage(RaidWarningFrame, "PRESS HERO NOW!", ChatTypeInfo["RAID_WARNING"])
            
            -- Print to chat with details
            print(string.format("|cff00ffff[Press Hero]|r |cff00ff00PRESS IT!|r (%s requested by %s)", spellName, coloredSender))
            
            -- Optional: Flash screen or show additional UI indicator
            if not UnitIsDeadOrGhost("player") then
                -- Flash the screen briefly
                UIFrameFlash(WorldFrame, 0.5, 0.5, 1, false, 0, 0)
            end
        else
            -- Inform the requester that no one can press hero
            local reason = "No hero spells available"
            if UnitIsDeadOrGhost("player") then
                reason = "Player is dead"
            elseif AuraUtil.FindAuraByName("Sated", "player", "HARMFUL") then
                reason = "Player has Sated debuff (Heroism/Bloodlust)"
            elseif AuraUtil.FindAuraByName("Temporal Displacement", "player", "HARMFUL") then
                reason = "Player has Temporal Displacement debuff (Time Warp/Fury of the Aspects)"
            elseif AuraUtil.FindAuraByName("Exhaustion", "player", "HARMFUL") then
                reason = "Player has Exhaustion debuff (Primal Rage)"
            end
            
            print(string.format("|cff00ffff[Press Hero]|r |cffff0000Cannot press hero:|r %s", reason))
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
        
        -- Check if we can press hero ourselves
        local canPress, spellID, spellName = CanPressHero()
        if canPress then
            print(string.format("|cff00ffff[Press Hero]|r |cff00ff00You can press hero!|r (%s)", spellName))
            -- Optional: Auto-cast the spell
            if msg == "auto" then
                UseSpellByID(spellID)
                print("|cff00ffff[Press Hero]|r |cff00ff00Auto-cast %s!|r", spellName)
            end
        end
        
        -- Send request to group
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

    -- Add a function to check hero status on demand
    local function CheckHeroStatus()
        local canPress, spellID, spellName = CanPressHero()
        if canPress then
            local start, duration = GetSpellCooldown(spellID)
            local remaining = math.max(0, start + duration - GetTime())
            if remaining > 0 then
                print(string.format("|cff00ffff[Press Hero]|r |cff00ff00%s ready in %.1f seconds|r", spellName, remaining))
            else
                print(string.format("|cff00ffff[Press Hero]|r |cff00ff00%s ready now!|r", spellName))
            end
        else
            print("|cff00ffff[Press Hero]|r |cffff0000No hero spells available|r")
        end
    end

    -- Add status check command
    SLASH_PRESSHEROSTATUS1 = "/herostatus"
    SlashCmdList["PRESSHEROSTATUS"] = CheckHeroStatus

    -- Add debug command to test addon communication
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

    BINDING_NAME_PRESSHERO = "Press Hero: Request Heroism/Bloodlust/Time Warp"
end

-- Ensure all logic runs after PLAYER_LOGIN
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitializePressHero()
    end
end)
