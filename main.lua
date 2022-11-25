-- require('mobdebug').start()
-- StartDebug()
Memento = RegisterMod("isaac-memento", 1)
local mod = Memento

require "mem_config"
require "mem_tcp"
require "mem_data"

Memento.Version = "1.0"
Memento.Tcpclient = nil
Memento.InitialInit = false
Memento.IsItContinue = false

Memento.IconSprite = Sprite()
Memento.IconSprite:Load("icon.anm2", true)

-- init local variables
-- local text2print = Game():GetSeeds():GetStartSeedString()
local lastCharge = {}
local lastHealth = {}
local lastStats = {}
local lastLoot = {}
local lastSeed = {}
local lastItems = {}
local lastPills = {}

local daba = (Game().TimeCounter) / 30
lastCharge.cooldown = daba
lastHealth.cooldown = daba
lastStats.cooldown = daba
lastLoot.cooldown = daba
lastItems.cooldown = daba
lastPills.cooldown = daba

function Memento:sendAll()
    Memento:SendMessage(Memento:GetSeed())
    Memento:SendMessage(Memento:GetLevel())
    Memento:SendMessage(Memento:GetRoom())
    local current_l = Game():GetLevel():GetAbsoluteStage()
    local current_r = Game():GetLevel():GetCurrentRoomIndex()
    for i = 0, Game():GetNumPlayers() - 1 do

        local tosend = Memento:GetCharge(i)
        tosend.level = current_l
        tosend.room = current_r
        Memento:SendMessage(tosend)

        tosend = Memento:GetHealth(i)
        tosend.level = current_l
        tosend.room = current_r
        Memento:SendMessage(tosend)

        tosend = Memento:GetPlayer(i)
        tosend.level = current_l
        tosend.room = current_r
        Memento:SendMessage(tosend)

        tosend = Memento:GetItems(i)
        tosend.level = current_l
        tosend.room = current_r
        Memento:SendMessage(tosend)

        tosend = Memento:GetLoot(i)
        tosend.level = current_l
        tosend.room = current_r
        Memento:SendMessage(tosend)

        tosend = Memento:GetPillEffects(i)
        tosend.level = current_l
        tosend.room = current_r
        Memento:SendMessage(tosend)
    end

end

function mod:init(player)
    Isaac.DebugString("Initialize networking...")

    Memento:TryConnect(false)
end

function mod:render()
    if Memento.Tcpclient then
        Memento.IconSprite:Update()
        Memento.IconSprite:Render(Vector(4, 4), Vector(0, 0), Vector(0, 0))
    end
    if Memento.Token == "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" then
        Isaac.RenderText("[Memento] Invalid Token", 0, 0, 1, 1, 1, 255)
    end
end

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

function mod:update()
    if Memento.Token == "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" then
        Memento:ClearCallback()
    end

    -- if Isaac.GetFrameCount() % 60 == 0 then
    --     Memento:TryConnect(false)
    -- end
    if Isaac.GetFrameCount() < 10 then
        return
    end


    local l = Game():GetLevel()
    local r = l:GetCurrentRoomDesc()
    local s = Game():GetSeeds()
    local t = (Game().TimeCounter) / 30

    if Memento.InitialInit then
        -- Show Icon in HUD
        if Memento.Tcpclient then
            Memento.IconSprite:Play("icon", true)
        end

        -- Inform the server that game has started
        local msg = {
            type = "game-status",
            status = "started",
            difficulty = Game().Difficulty,
            continue = Memento.IsItContinue,
            name = Game():GetPlayer(0):GetPlayerType()
        }
        if REPENTANCE then
            msg.isaac = "Repentance"
        else
            msg.isaac = "AB+"
        end
        -- Memento:TryConnect(false)
        Memento:SendMessage(msg)

        -- Initialize global variables
        for i = 0, Game():GetNumPlayers() - 1 do
            lastCharge[i] = Memento:GetCharge(i)
            lastHealth[i] = Memento:GetHealth(i)
            lastStats[i] = Memento:GetPlayer(i)
            lastLoot[i] = Memento:GetLoot(i)
            lastItems[i] = Memento:GetItems(i)
            lastPills[i] = Memento:GetPillEffects(i)
        end


        lastSeed = Memento:GetSeed()
        daba = (Game().TimeCounter) / 30
        lastCharge.cooldown = daba
        lastHealth.cooldown = daba
        lastStats.cooldown = daba
        lastLoot.cooldown = daba
        lastItems.cooldown = daba
        lastPills.cooldown = daba

        Memento.InitialInit = false

        Memento:sendAll()
    else
        for i = 0, Game():GetNumPlayers() - 1 do
            local p = Game():GetPlayer(i)

            if (t - lastCharge.cooldown > 0.5) then

                if (dump(Memento:GetCharge(i)) ~= dump(lastCharge[i])) then
                    local tosend = Memento:GetCharge(i)
                    -- append room and level info
                    tosend.level = l:GetAbsoluteStage()
                    tosend.room = l:GetCurrentRoomIndex()

                    Memento:SendMessage(tosend)

                    lastCharge[i] = Memento:GetCharge(i)
                    lastCharge.cooldown = t
                end
            end

            if (t - lastHealth.cooldown > 0.5) then

                if (dump(Memento:GetHealth(i)) ~= dump(lastHealth[i])) then

                    local tosend = Memento:GetHealth(i)
                    -- append room and level info
                    tosend.level = l:GetAbsoluteStage()
                    tosend.room = l:GetCurrentRoomIndex()

                    Memento:SendMessage(tosend)

                    lastHealth[i] = Memento:GetHealth(i)
                    lastHealth.cooldown = t

                end
            end

            if (t - lastStats.cooldown > 0.5) then

                if (dump(Memento:GetPlayer(i)) ~= dump(lastStats[i])) then

                    local tosend = Memento:GetPlayer(i)
                    -- append room and level info
                    tosend.level = l:GetAbsoluteStage()
                    tosend.room = l:GetCurrentRoomIndex()

                    Memento:SendMessage(tosend)

                    lastStats[i] = Memento:GetPlayer(i)
                    lastStats.cooldown = t
                end
            end
            if (t - lastPills.cooldown > 0.5) then
                if (dump(Memento:GetPillEffects(i)) ~= dump(lastPills[i])) then

                    local tosend = Memento:GetPillEffects(i)
                    -- append room and level info
                    tosend.level = l:GetAbsoluteStage()
                    tosend.room = l:GetCurrentRoomIndex()

                    Memento:SendMessage(tosend)

                    lastPills[i] = Memento:GetPillEffects(i)
                    lastPills.cooldown = t
                end
            end
            if (t - lastItems.cooldown > 0.5) then
                if (dump(Memento:GetItems(i)) ~= dump(lastItems[i])) then
                    local tosend = Memento:GetItems(i)
                    -- append room and level info
                    tosend.level = l:GetAbsoluteStage()
                    tosend.room = l:GetCurrentRoomIndex()

                    Memento:SendMessage(tosend)

                    lastItems[i] = Memento:GetItems(i)
                    lastItems.cooldown = t
                end
            end

            if (t - lastLoot.cooldown > 0.5) then
                if (dump(Memento:GetLoot(i)) ~= dump(lastLoot[i])) then
                    local tosend = Memento:GetLoot(i)
                    -- append room and level info
                    tosend.level = l:GetAbsoluteStage()
                    tosend.room = l:GetCurrentRoomIndex()

                    Memento:SendMessage(tosend)

                    lastLoot[i] = Memento:GetLoot(i)
                    lastLoot.cooldown = t
                end
            end
            -- end

            if s:IsInitialized() == true and (dump(Memento:GetSeed()) ~= dump(lastSeed)) then
                Memento:SendMessage(Memento:GetSeed())
                lastSeed = Memento:GetSeed()
            end

        end
    end

end

local function onStart(_, bool)
    local msg = {
        type = "game-status",
        status = "initialized",
        continue = bool,
        difficulty = Game().Difficulty,
        session_timeplayed = Isaac.GetFrameCount() / 60,
        name = Game():GetPlayer(0):GetPlayerType(),
        challenge = Isaac.GetChallenge()
    }
    Memento.IsItContinue = bool
    if REPENTANCE then
        msg.isaac = "Repentance"
    else
        msg.isaac = "AB+"
    end
    Memento:TryConnect(true)

    Memento:SendMessage(msg)
    -- clearVars()
end

local function onEnd(_, bool)
    local msg = {
        type = "game-status",
        status = "ended",
        died = bool,
        continue = false,
        difficulty = Game().Difficulty,
        session_timeplayed = Isaac.GetFrameCount() / 60,
        name = Game():GetPlayer(0):GetPlayerType(),
        challenge = Isaac.GetChallenge()
    }
    if REPENTANCE then
        msg.isaac = "Repentance"
    else
        msg.isaac = "AB+"
    end
    Memento:SendMessage(msg)
    Memento.InitialInit = false

    -- clearVars()
end

local function onExit(_, bool)
    local msg = {
        type = "game-status",
        status = "exited",
        continue = bool,
        difficulty = Game().Difficulty,
        session_timeplayed = Isaac.GetFrameCount() / 60,
        name = Game():GetPlayer(0):GetPlayerType(),
        challenge = Isaac.GetChallenge()
    }
    if REPENTANCE then
        msg.isaac = "Repentance"
    else
        msg.isaac = "AB+"
    end
    Memento:SendMessage(msg)
    Memento.InitialInit = false

    -- clearVars()
end

local function onNewLevel()
    Memento:sendAll()
    -- Memento:SendMessage(GetLevel())
    -- Memento:SendMessage(GetRoom())
end

-- local function clearVars()
-- 	-- init local variables
-- 	lastCharge = {}
-- 	lastHealth = {}
-- 	lastStats = {}
-- 	lastLoot = {}
-- 	lastSeed = {}
-- 	lastItems = {}
-- 	lastStage = {}

-- 	InitialInit = true

-- end

local function onNewRoom()

    local room = Memento:GetRoom()
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

    Memento:SendMessage(room)

end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onStart)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, onEnd)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, onExit)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewLevel)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)

function Memento:ClearCallback()
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.init)
    mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, mod.update)
    -- mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, mod.render)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, onStart)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_END, onEnd)
    mod:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT, onExit)
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewLevel)
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)
end

for i, v in pairs(ModCallbacks) do
    mod:AddCallback(v, function(...)
        if mod[i] then
            local args = table.pack(...)
            local ok, result = pcall(function()
                mod[i](table.unpack(args))
            end)
            if not ok and Memento.Tcpclient then
                Memento:SendMessage {
                    type = "err",
                    token = Memento.Token,
                    msg = "Failed to execute " .. v .. ": " .. tostring(result)
                }
            end
        end
    end)
end
