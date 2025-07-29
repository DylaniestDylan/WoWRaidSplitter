-- WoW Raid Splitter Addon
-- Allows party-specific raid warnings within raids

local addonName = "WoWRaidSplitter"
local WRS = {}
_G[addonName] = WRS

-- Initialize saved variables
WoWRaidSplitterDB = WoWRaidSplitterDB or {}

-- Event frame
local eventFrame = CreateFrame("Frame")

-- Check if player has raid privileges (leader or assist)
local function HasRaidPrivileges()
    if not IsInRaid() then
        return false
    end
    
    local playerName = UnitName("player")
    local isLeader = UnitIsGroupLeader("player")
    local isAssist = UnitIsGroupAssistant("player")
    
    return isLeader or isAssist
end

-- Get all players in a specific party within the raid
local function GetPartyMembers(partyNumber)
    if not IsInRaid() then
        return {}
    end
    
    local members = {}
    local numGroupMembers = GetNumGroupMembers()
    
    for i = 1, numGroupMembers do
        local unit = "raid" .. i
        local name, rank, subgroup = GetRaidRosterInfo(i)
        
        if name and subgroup == partyNumber then
            table.insert(members, name)
        end
    end
    
    return members
end

-- Send raid warning to specific party
local function SendPartyRaidWarning(partyNumber, message)
    if not HasRaidPrivileges() then
        print("|cffff0000[WoW Raid Splitter]|r You need to be raid leader or assist to send raid warnings!")
        return
    end
    
    if not IsInRaid() then
        print("|cffff0000[WoW Raid Splitter]|r You must be in a raid to use this feature!")
        return
    end
    
    if partyNumber < 1 or partyNumber > 8 then
        print("|cffff0000[WoW Raid Splitter]|r Invalid party number! Use 1-8.")
        return
    end
    
    local partyMembers = GetPartyMembers(partyNumber)
    
    if #partyMembers == 0 then
        print("|cffff0000[WoW Raid Splitter]|r No members found in party " .. partyNumber .. "!")
        return
    end
    
    -- Send whisper with raid warning format to each party member
    for _, memberName in ipairs(partyMembers) do
        SendChatMessage("[PARTY " .. partyNumber .. " WARNING] " .. message, "WHISPER", nil, memberName)
    end
    
    -- Also display locally for feedback
    print("|cff00ff00[WoW Raid Splitter]|r Sent party warning to " .. #partyMembers .. " members in party " .. partyNumber .. ": " .. message)
end

-- Send raid warning to all parties except specified ones
local function SendExcludePartyRaidWarning(excludeParties, message)
    if not HasRaidPrivileges() then
        print("|cffff0000[WoW Raid Splitter]|r You need to be raid leader or assist to send raid warnings!")
        return
    end
    
    if not IsInRaid() then
        print("|cffff0000[WoW Raid Splitter]|r You must be in a raid to use this feature!")
        return
    end
    
    local sentCount = 0
    
    for party = 1, 8 do
        local shouldSend = true
        
        -- Check if this party should be excluded
        for _, excludeParty in ipairs(excludeParties) do
            if party == excludeParty then
                shouldSend = false
                break
            end
        end
        
        if shouldSend then
            local partyMembers = GetPartyMembers(party)
            for _, memberName in ipairs(partyMembers) do
                SendChatMessage("[RAID WARNING] " .. message, "WHISPER", nil, memberName)
                sentCount = sentCount + 1
            end
        end
    end
    
    print("|cff00ff00[WoW Raid Splitter]|r Sent raid warning to " .. sentCount .. " members (excluding specified parties): " .. message)
end

-- List all parties and their members
local function ListParties()
    if not IsInRaid() then
        print("|cffff0000[WoW Raid Splitter]|r You must be in a raid to list parties!")
        return
    end
    
    print("|cff00ffff[WoW Raid Splitter]|r Current raid composition:")
    
    for party = 1, 8 do
        local members = GetPartyMembers(party)
        if #members > 0 then
            print("|cffffff00Party " .. party .. ":|r")
            for _, memberName in ipairs(members) do
                print("  - " .. memberName)
            end
        end
    end
end

-- Slash command handlers
SLASH_WOWRAIDSPLITTER1 = "/wrs"
SLASH_WOWRAIDSPLITTER2 = "/raidsplit"

function SlashCmdList.WOWRAIDSPLITTER(msg, editBox)
    local command, args = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()
    
    if command == "" or command == "help" then
        print("|cff00ffff[WoW Raid Splitter]|r Commands:")
        print("  |cffffff00/wrs party <number> <message>|r - Send raid warning to specific party (1-8)")
        print("  |cffffff00/wrs exclude <party1,party2...> <message>|r - Send raid warning to all except specified parties")
        print("  |cffffff00/wrs list|r - List all parties and their members")
        print("  |cffffff00/wrs help|r - Show this help")
        print("Example: |cffffff00/wrs party 1 Stack on tank!|r")
        print("Example: |cffffff00/wrs exclude 1,2 DPS focus boss!|r")
        
    elseif command == "party" then
        local partyNumber, message = args:match("^(%d+)%s+(.+)$")
        if partyNumber and message then
            SendPartyRaidWarning(tonumber(partyNumber), message)
        else
            print("|cffff0000[WoW Raid Splitter]|r Usage: /wrs party <number> <message>")
        end
        
    elseif command == "exclude" then
        local excludeList, message = args:match("^([%d,]+)%s+(.+)$")
        if excludeList and message then
            local excludeParties = {}
            for partyStr in excludeList:gmatch("(%d+)") do
                local partyNum = tonumber(partyStr)
                if partyNum >= 1 and partyNum <= 8 then
                    table.insert(excludeParties, partyNum)
                end
            end
            SendExcludePartyRaidWarning(excludeParties, message)
        else
            print("|cffff0000[WoW Raid Splitter]|r Usage: /wrs exclude <party1,party2...> <message>")
        end
        
    elseif command == "list" then
        ListParties()
        
    else
        print("|cffff0000[WoW Raid Splitter]|r Unknown command. Use /wrs help for available commands.")
    end
end

-- Event handlers
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddonName = ...
        if loadedAddonName == addonName then
            print("|cff00ff00[WoW Raid Splitter]|r Loaded! Use /wrs help for commands.")
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Could add functionality here to auto-detect party changes
    end
end

-- Register events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:SetScript("OnEvent", OnEvent)

-- Export functions for potential use by other addons
WRS.SendPartyRaidWarning = SendPartyRaidWarning
WRS.SendExcludePartyRaidWarning = SendExcludePartyRaidWarning
WRS.GetPartyMembers = GetPartyMembers
WRS.HasRaidPrivileges = HasRaidPrivileges
WRS.ListParties = ListParties
