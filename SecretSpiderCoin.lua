-- ==================================================
-- Secret Spider Coin v3.0 (Turtle WoW / Vanilla)
-- ==================================================

SSC_PREFIX = "SSC"

-- ======================
-- SavedVariables
-- ======================

if not SecretSpiderCoinDB then
    SecretSpiderCoinDB = {
        balances = {},
        distributors = {},
        guildMaster = nil,
        history = {}
    }
end

-- ======================
-- Utility
-- ======================

local function Player()
    return UnitName("player")
end

local function IsVanillaGuildMaster()
    if not IsInGuild() then return false end
    local _, _, rankIndex = GetGuildInfo("player")
    return rankIndex == 0
end

local function IsGuildMaster()
    return SecretSpiderCoinDB.guildMaster == Player()
end

local function IsAuthorized()
    return IsGuildMaster() or SecretSpiderCoinDB.distributors[Player()]
end

local function Log(action)
    table.insert(SecretSpiderCoinDB.history, date("%H:%M:%S") .. " " .. action)
end

-- ======================
-- Guild Master Lock
-- ======================

local function InitGuildMaster()
    if not SecretSpiderCoinDB.guildMaster and IsVanillaGuildMaster() then
        SecretSpiderCoinDB.guildMaster = Player()
        print("|cff00ff00[SSC]|r Guild Master locked to " .. Player())
    end
end

-- ======================
-- Communication
-- ======================

local function Broadcast(msg)
    if IsInGuild() then
        SendAddonMessage(SSC_PREFIX, msg, "GUILD")
    end
end

-- ======================
-- Coin Logic
-- ======================

local function SetCoins(name, amount)
    SecretSpiderCoinDB.balances[name] = amount
end

local function AddCoins(name, amount)
    local new = (SecretSpiderCoinDB.balances[name] or 0) + amount
    SecretSpiderCoinDB.balances[name] = new
    Log(Player() .. " changed " .. name .. " by " .. amount)
    Broadcast("SET|" .. name .. "|" .. new)
end

-- ======================
-- Announcements
-- ======================

local function Say(msg, channel)
    SendChatMessage(msg, channel)
end

local function AnnounceBalance(name, channel)
    Say(name .. " has " ..
        (SecretSpiderCoinDB.balances[name] or 0) ..
        " Secret Spider Coins", channel)
end

-- ======================
-- Top 10
-- ======================

local function AnnounceTop10(channel)
    local list = {}
    for n, a in pairs(SecretSpiderCoinDB.balances) do
        table.insert(list, {n=n,a=a})
    end

    table.sort(list, function(x,y) return x.a > y.a end)

    Say("Top 10 Secret Spider Coins:", channel)
    for i=1, math.min(10, getn(list)) do
        Say(i .. ". " .. list[i].n .. " - " .. list[i].a, channel)
    end
end

-- ======================
-- Amount Input Popup
-- ======================

StaticPopupDialogs["SSC_AMOUNT"] = {
    text = "Enter coin amount:",
    button1 = "Confirm",
    button2 = "Cancel",
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function(self)
        local amt = tonumber(self.editBox:GetText())
        if not amt or amt == 0 then return end
        AddCoins(self.data.target, amt * self.data.mult)
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        parent.button1:Click()
    end
}

-- ======================
-- Right Click Menu
-- ======================

UnitPopupButtons["SSC_MENU"] = { text = "Secret Spider Coin", dist = 0 }
table.insert(UnitPopupMenus["PLAYER"], "SSC_MENU")

hooksecurefunc("UnitPopup_OnClick", function(self)
    if self.value ~= "SSC_MENU" then return end
    if not IsAuthorized() then return end

    local target = UnitName("target")
    if not target then return end

    StaticPopupDialogs["SSC_ACTION"] = {
        text = "Secret Spider Coin: " .. target,
        button1 = "Add",
        button2 = "Remove",
        button3 = "Announce",
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,

        OnAccept = function()
            StaticPopup_Show("SSC_AMOUNT", nil, nil,
                { target=target, mult=1 })
        end,

        OnCancel = function()
            StaticPopup_Show("SSC_AMOUNT", nil, nil,
                { target=target, mult=-1 })
        end,

        OnAlt = function()
            StaticPopup_Show("SSC_CHANNEL", nil, nil, target)
        end
    }

    StaticPopup_Show("SSC_ACTION")
end)

-- ======================
-- Channel Picker
-- ======================

StaticPopupDialogs["SSC_CHANNEL"] = {
    text = "Announce to:",
    button1 = "Guild",
    button2 = "Party",
    button3 = "Raid",
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,

    OnAccept = function(self) AnnounceBalance(self.data,"GUILD") end,
    OnCancel = function(self) AnnounceBalance(self.data,"PARTY") end,
    OnAlt = function(self) AnnounceBalance(self.data,"RAID") end
}

-- ======================
-- Slash Commands
-- ======================

SLASH_SSC1 = "/ssc"
SlashCmdList["SSC"] = function(msg)
    if msg == "top guild" then AnnounceTop10("GUILD")
    elseif msg == "top party" then AnnounceTop10("PARTY")
    elseif msg == "top raid" then AnnounceTop10("RAID")
    elseif msg == "history" then
        for _,v in ipairs(SecretSpiderCoinDB.history) do
            print(v)
        end
    end
end

-- ======================
-- Events
-- ======================

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_ADDON")

f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "SecretSpiderCoin" then
        InitGuildMaster()
        RegisterAddonMessagePrefix(SSC_PREFIX)
        print("|cff00ff00Secret Spider Coin v3.0 loaded.|r")
    end

    if event == "CHAT_MSG_ADDON" and arg1 == SSC_PREFIX then
        local cmd,name,amt = strsplit("|", arg2)
        if cmd == "SET" then
            SecretSpiderCoinDB.balances[name] = tonumber(amt)
        end
    end
end)
