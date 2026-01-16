-- =====================================
-- Secret Spider Coin (Turtle WoW)
-- =====================================

SECRETSPIDER_PREFIX = "SSC"

-- SavedVariables
if not SecretSpiderCoinDB then
    SecretSpiderCoinDB = {
        balances = {},
        distributors = {},
        guildMaster = nil
    }
end

-- ==============================
-- Utilities
-- ==============================

local function Player()
    return UnitName("player")
end

local function IsGuildMaster()
    if not IsInGuild() then return false end
    local _, _, rankIndex = GetGuildInfo("player")
    return rankIndex == 0
end

local function IsAuthorized()
    return Player() == SecretSpiderCoinDB.guildMaster
        or SecretSpiderCoinDB.distributors[Player()]
end

-- Lock guild master permanently
local function InitializeGuildMaster()
    if not SecretSpiderCoinDB.guildMaster and IsGuildMaster() then
        SecretSpiderCoinDB.guildMaster = Player()
        print("|cff00ff00Secret Spider Coin: Guild Master locked to|r", Player())
    end
end

-- ==============================
-- Communication
-- ==============================

local function Broadcast(msg)
    if IsInGuild() then
        SendAddonMessage(SECRETSPIDER_PREFIX, msg, "GUILD")
    end
end

-- ==============================
-- Coin Logic
-- ==============================

local function SetCoins(name, amount)
    SecretSpiderCoinDB.balances[name] = amount
end

local function AddCoins(name, amount)
    SetCoins(name, (SecretSpiderCoinDB.balances[name] or 0) + amount)
end

-- ==============================
-- Announce Balance
-- ==============================

local function AnnounceBalance(target, channel)
    local amount = SecretSpiderCoinDB.balances[target] or 0
    SendChatMessage(
        target .. " has " .. amount .. " Secret Spider Coins",
        channel
    )
end

-- ==============================
-- Top 10
-- ==============================

local function AnnounceTop10(channel)
    local list = {}
    for name, amount in pairs(SecretSpiderCoinDB.balances) do
        table.insert(list, {name=name, amount=amount})
    end

    table.sort(list, function(a,b) return a.amount > b.amount end)

    SendChatMessage("Top 10 Secret Spider Coins:", channel)
    for i = 1, math.min(10, getn(list)) do
        SendChatMessage(
            i .. ". " .. list[i].name .. " - " .. list[i].amount,
            channel
        )
    end
end

-- ==============================
-- Right Click Menu Injection
-- ==============================

UnitPopupButtons["SECRETSPIDER"] = {
    text = "Secret Spider Coin",
    dist = 0
}

UnitPopupMenus["PLAYER"] = UnitPopupMenus["PLAYER"] or {}
table.insert(UnitPopupMenus["PLAYER"], "SECRETSPIDER")

hooksecurefunc("UnitPopup_OnClick", function(self)
    if self.value ~= "SECRETSPIDER" then return end
    local target = UnitName("target")
    if not target then return end

    StaticPopupDialogs["SSC_PLAYER_MENU"] = {
        text = "Secret Spider Coin: " .. target,
        button1 = "Add 10",
        button2 = "Remove 10",
        button3 = "Announce",
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,

        OnAccept = function()
            if not IsAuthorized() then return end
            AddCoins(target, 10)
            Broadcast("SET|"..target.."|"..SecretSpiderCoinDB.balances[target])
        end,

        OnCancel = function()
            if not IsAuthorized() then return end
            AddCoins(target, -10)
            Broadcast("SET|"..target.."|"..SecretSpiderCoinDB.balances[target])
        end,

        OnAlt = function()
            AnnounceBalance(target, "GUILD")
        end
    }

    StaticPopup_Show("SSC_PLAYER_MENU")
end)

-- ==============================
-- Slash Commands
-- ==============================

SLASH_SECRETSPIDER1 = "/ssc"
SlashCmdList["SECRETSPIDER"] = function(msg)
    if msg == "top" then
        AnnounceTop10("GUILD")
    elseif msg == "top raid" then
        AnnounceTop10("RAID")
    elseif msg == "top party" then
        AnnounceTop10("PARTY")
    end
end

-- ==============================
-- Event Handler
-- ==============================

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_ADDON")

f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "SecretSpiderCoin" then
        InitializeGuildMaster()
        RegisterAddonMessagePrefix(SECRETSPIDER_PREFIX)
        print("|cff00ff00Secret Spider Coin loaded.|r")
    end

    if event == "CHAT_MSG_ADDON" and arg1 == SECRETSPIDER_PREFIX then
        local cmd, name, amount = strsplit("|", arg2)
        if cmd == "SET" then
            SetCoins(name, tonumber(amount))
        end
    end
end)
