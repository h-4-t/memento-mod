-- require('mobdebug').start()
-- StartDebug()
local mod = RegisterMod("isaac-memento", 1)

require "data"

Tcpclient = nil

require "srv"

InitialInit = false
local text2print = Game():GetSeeds():GetStartSeedString()
IsItContinue = false

IconSprite = Sprite()
IconSprite:Load("icon.anm2", true)

function mod:init(player)
    Isaac.DebugString("Initialize networking...")

    TryConnect(false)
end

function mod:render()
    if Tcpclient then
        IconSprite:Update()
        IconSprite:Render(Vector(4, 4), Vector(0, 0), Vector(0, 0))

    end

end

-- init local variables
local lastCharge = {}
local lastHealth = {}
local lastStats = {}
local lastLoot = {}
local lastSeed = {}
local lastItems = {}
local lastStage = {}


local daba = (Game().TimeCounter) / 30
lastCharge.cooldown = daba
lastHealth.cooldown = daba
lastStats.cooldown = daba
lastLoot.cooldown = daba
lastItems.cooldown = daba

-- https://www.luafaq.org/#T1.15
-- used to compare change in stats in strings O(1) vs deep compare O(n)
local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function sendAll()
    SendMessage(GetSeed())
    SendMessage(GetLevel())
    SendMessage(GetRoom())
    local current_l = Game():GetLevel():GetAbsoluteStage()
    local current_r = Game():GetLevel():GetCurrentRoomIndex()
    for i = 0, Game():GetNumPlayers() - 1 do

        local tosend = GetCharge(i)
        tosend.level = current_l
        tosend.room = current_r
        SendMessage(tosend)

        tosend = GetHealth(i)
        tosend.level = current_l
        tosend.room = current_r
        SendMessage(tosend)

        tosend = GetPlayer(i)
        tosend.level = current_l
        tosend.room = current_r
        SendMessage(tosend)

        tosend = GetItems(i)
        tosend.level = current_l
        tosend.room = current_r
        SendMessage(tosend)

        tosend = GetLoot(i)
        tosend.level = current_l
        tosend.room = current_r
        SendMessage(tosend)

    end

end

function mod:update()
    if Tcpclient then
        local cmd, err = Tcpclient:receive("*line")
        if err and err ~= "timeout" then
            Isaac.DebugString("CLI: " .. err)

            Tcpclient = nil
            return
        end

        if cmd then
            Isaac.DebugString("Received command: " .. tostring(cmd))
            _G["mod"] = mod
            local ok, err = pcall(function()
                local command, err = load("return " .. cmd)
                if command then
                    local data = command()
                    if data.type == "text2print" then
                        text2print = tostring(data.code)
                        if text2print == "plzRegister" then
                            --- disable mod 
                            Game():GetHUD():ShowFortuneText("Memento", "Please register")
                            mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)
                            mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
                            mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, mod.render)
                        else
                            Game():GetHUD():ShowFortuneText(text2print)
                        end
                    end
                else
                    SendMessage {
                        type = "err-status",
                        msg = ("Failed to unpack data: " .. tostring(err))
                    }
                end
            end)
            if not ok then
                SendMessage {
                    type = "err-status",
                    msg = err or "Unknown error!"
                }
            end
            _G["mod"] = nil
        end
    else
        if Isaac.GetFrameCount() % 60 == 0 then
            TryConnect(false)
        end
    end

    if Isaac.GetFrameCount() < 10 then
        return
    end

    local l = Game():GetLevel()
    local r = l:GetCurrentRoomDesc()
    local s = Game():GetSeeds()
    local t = (Game().TimeCounter) / 30

    if InitialInit then
        -- Show Icon in HUD
        if Tcpclient then
            IconSprite:Play("icon", true)
        end

        -- Inform the server that game has started
        local msg = {
            type = "game-status",
            status = "started",
            difficulty = Game().Difficulty,
            continue = IsItContinue,
            player = Game():GetPlayer(0):GetPlayerType()
        }
        if REPENTANCE then
            msg.isaac = "Repentance"
        else
            msg.isaac = "AB+"
        end
        -- TryConnect(false)
        SendMessage(msg)

        sendAll()
        -- Initialize global variables
        for i = 0, Game():GetNumPlayers() - 1 do
            lastCharge[i] = GetCharge(i)
            lastHealth[i] = GetHealth(i)
            lastStats[i] = GetPlayer(i)
            lastLoot[i] = GetLoot(i)
            lastItems[i] = GetItems(i)
        end

        lastSeed = GetSeed()
        lastStage = Game():GetLevel():GetAbsoluteStage()

        InitialInit = false
        -- Game():GetHUD():ShowFortuneText("Memento", "Up and recording!")    
    else
        if Game():GetLevel():GetAbsoluteStage() ~= lastStage then
            sendAll()
            lastStage = Game():GetLevel():GetAbsoluteStage()
        else
            for i = 0, Game():GetNumPlayers() - 1 do
                local p = Game():GetPlayer(i)

                if (t - lastCharge.cooldown > 0.5) then

                    if (dump(GetCharge(i)) ~= dump(lastCharge[i])) then
                        local tosend = GetCharge(i)
                        -- append room and level info
                        tosend.level = l:GetAbsoluteStage()
                        tosend.room = l:GetCurrentRoomIndex()

                        SendMessage(tosend)

                        lastCharge[i] = GetCharge(i)
                        lastCharge.cooldown = t
                    end
                end

                if (t - lastHealth.cooldown > 0.5) then

                    if (dump(GetHealth(i)) ~= dump(lastHealth[i])) then

                        local tosend = GetHealth(i)
                        -- append room and level info
                        tosend.level = l:GetAbsoluteStage()
                        tosend.room = l:GetCurrentRoomIndex()

                        SendMessage(tosend)

                        lastHealth[i] = GetHealth(i)
                        lastHealth.cooldown = t

                    end
                end

                if (t - lastStats.cooldown > 0.5) then

                    if (dump(GetPlayer(i)) ~= dump(lastStats[i])) then

                        local tosend = GetPlayer(i)
                        -- append room and level info
                        tosend.level = l:GetAbsoluteStage()
                        tosend.room = l:GetCurrentRoomIndex()

                        SendMessage(tosend)

                        lastStats[i] = GetPlayer(i)
                        lastStats.cooldown = t
                    end
                end

                if (t - lastItems.cooldown > 0.5) then
                    if (dump(GetItems(i)) ~= dump(lastItems[i])) then
                        local tosend = GetItems(i)
                        -- append room and level info
                        tosend.level = l:GetAbsoluteStage()
                        tosend.room = l:GetCurrentRoomIndex()

                        SendMessage(tosend)

                        lastItems[i] = GetItems(i)
                        lastItems.cooldown = t
                    end
                end

                if (t - lastLoot.cooldown > 0.5) then
                    if (dump(GetLoot(i)) ~= dump(lastLoot[i])) then
                        local tosend = GetLoot(i)
                        -- append room and level info
                        tosend.level = l:GetAbsoluteStage()
                        tosend.room = l:GetCurrentRoomIndex()

                        SendMessage(tosend)

                        lastLoot[i] = GetLoot(i)
                        lastLoot.cooldown = t
                    end
                end
            end

            if s:IsInitialized() == true and (dump(GetSeed()) ~= dump(lastSeed)) then
                SendMessage(GetSeed())
                lastSeed = GetSeed()

            end

        end
    end

end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)

local function onStart(_, bool)
    local msg = {
        type = "game-status",
        status = "initialized",
        continue = bool,
        difficulty = Game().Difficulty,
        session_timeplayed = Isaac.GetFrameCount() / 60,
        player = Game():GetPlayer(0):GetPlayerType()
    }
    IsItContinue = bool
    if REPENTANCE then
        msg.isaac = "Repentance"
    else
        msg.isaac = "AB+"
    end
    TryConnect(true)

    SendMessage(msg)
    InitialInit = true
end

local function onEnd(_, bool)
    local msg = {
        type = "game-status",
        status = "ended",
        died = bool,
        continue = false,
        difficulty = Game().Difficulty,
        session_timeplayed = Isaac.GetFrameCount() / 60,
        player = Game():GetPlayer(0):GetPlayerType()
    }
    if REPENTANCE then
        msg.isaac = "Repentance"
    else
        msg.isaac = "AB+"
    end
    SendMessage(msg)

    InitialInit = false
end

local function onExit(_, bool)
    local msg = {
        type = "game-status",
        status = "exited",
        continue = bool,
        difficulty = Game().Difficulty,
        session_timeplayed = Isaac.GetFrameCount() / 60,
        player = Game():GetPlayer(0):GetPlayerType()
    }
    if REPENTANCE then
        msg.isaac = "Repentance"
    else
        msg.isaac = "AB+"
    end
    SendMessage(msg)

    InitialInit = false
end

local function onNewLevel()
    -- sendAll()
    SendMessage(GetLevel())
    SendMessage(GetRoom())

end

local function onNewRoom()

    local room = GetRoom()
    if not room.Clear then
        local entities = {}
        for _, v in pairs(Isaac.GetRoomEntities()) do
            -- selecting only enemies
            if (v.Type ~= 1000 and v.Type ~= 9001 and v.Type > 9) then
                local entity = {
                    type = v.Type,
                    variant = v.Variant,
                    subtype = v.SubType
                }
                table.insert(entities, entity)
            end
        end
        room.entities = entities

    end

    SendMessage(room)

end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onStart)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, onEnd)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, onExit)
-- unreliable? sometimes doesn't trigger (after a reset for example)
-- mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewLevel)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)

for i, v in pairs(ModCallbacks) do
    mod:AddCallback(v, function(...)
        if mod[i] then
            local args = table.pack(...)
            local ok, result = pcall(function()
                mod[i](table.unpack(args))
            end)
            if not ok and Tcpclient then
                SendMessage {
                    type = "err",
                    token = Token,
                    msg = "Failed to execute " .. v .. ": " .. tostring(result)
                }
            end
        end
    end)
end

