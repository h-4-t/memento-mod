local function cntBits(num)
    local r = 0
    for i = 0, 11 do
        -- Need to find a way to escape this lint error here
        if (num >> i) % 2 ~= 0 then
            r = r + 1
        end
    end
    return r
end

function GetHealth(playerid)
    local p = Game():GetPlayer(playerid)

    local msg = {
        type = "health-p"..playerid,
        playertype = p:GetPlayerType(),
        red = p:GetHearts(),
        max_red = p:GetMaxHearts(),
        soul = p:GetSoulHearts(),
        black = 2 * cntBits(p:GetBlackHearts()),
        blackmask = p:GetBlackHearts(),
        gold = p:GetGoldenHearts(),
        eternal = p:GetEternalHearts(),
        life = p:GetExtraLives(),
        has_fullred = p:HasFullHearts(),
        has_fullredsoul = p:HasFullHeartsAndSoulHearts(),
        bone = p:GetBoneHearts(),
        max_all = p:GetEffectiveMaxHearts(),
        jar_hearts = p:GetJarHearts() 
    }
    if REPENTANCE then
        msg.broken = p:GetBrokenHearts()
        msg.rotten = p:GetRottenHearts()
        msg.soul_charge = p:GetSoulCharge()
        msg.soul_effective = p:GetSoulCharge()
        msg.blood_charge = p:GetBloodCharge()
        msg.poop_mana =  p:GetPoopMana()
    end
    return msg
end

function GetPlayer(playerid)
    local p = Game():GetPlayer(playerid)
    
    local msg = {
        type = "player-p"..playerid,
        canfly = p.CanFly,
        damage = p.Damage,
        luck = p.Luck,
        maxfiredelay = p.MaxFireDelay,
        movespeed = p.MoveSpeed,
        shotspeed = p.ShotSpeed,
        tearflags = p.TearFlags,
        tearheight = p.TearHeight,
        tearfallingspeed = p.TearFallingSpeed,
        name = p:GetName(),
        playertype = p:GetPlayerType(),
        damage_taken = p:GetTotalDamageTaken(),
    }
    if REPENTANCE then
        msg.tearrange = p.TearRange
      end

    return msg
end

function GetSeed()
    local s = Game():GetSeeds()
    local l = Game():GetLevel()

    local msg = {
        type = "seed-status",
        count_effect = s:CountSeedEffects(),
        player_init = s:GetPlayerInitSeed(),
        start_seed = s:GetStartSeed(),
        start_string = s:GetStartSeedString(),

        custom_run = s:IsCustomRun(),
        challenge = Isaac.GetChallenge(),
        difficulty = Game().Difficulty
    }
    return msg
end

function GetLoot(playerid)
    local p = Game():GetPlayer(playerid)
    local msg = {
        type = "loot-p"..playerid,
        count_bombs = p:GetNumBombs(),
        count_coins = p:GetNumCoins(),
        count_keys = p:GetNumKeys(),
        has_gold_key = p:HasGoldenKey(),
        has_gold_bomb = p:HasGoldenBomb(),
        count_collectible = p:GetCollectibleCount()
    }
    return msg
end

function GetMaxCollectibleID()
    return Isaac.GetItemConfig():GetCollectibles().Size - 1
end

function ItemList(playerid)
    local itemz = {}
    local max = GetMaxCollectibleID()
    -- Hackish way to fix game crash when entering Mines II mini game to get knife part 2
    -- When in stage mining skip geting itemlist seems to be a good hack to avoid it
    local stage = Game():GetLevel():GetName()
    --local roomid = Game():GetLevel():GetCurrentRoomIndex()
    if string.find(stage, 'Mines II') or string.find(stage, 'Ashpit II') or string.find(stage, 'Mines XL') or
        string.find(stage, 'Ashpit XL') then
        return itemz
    else
        for i = 0, max, 1 do
            if (Game():GetPlayer(playerid):GetCollectibleNum(i) == 1) then
                table.insert(itemz, i)
            end
        end
        return itemz
    end
end

function PillEffects()
    local pillz = {}
    for i = 0, 15, 1 do
        local data = {}
        data.color = i
        data.effect = Game():GetItemPool():GetPillEffect(i, Game():GetPlayer(0))
        table.insert(pillz, data)
    end

    return pillz
end

function GetItems(playerid)
    local p = Game():GetPlayer(playerid)
    local l = Game():GetLevel()
    local msg = {
        type = "item-p"..playerid,
        items = ItemList(playerid),
        cards = {
            slot0 = p:GetCard(0),
            slot1 = p:GetCard(1)
        },
        trinkets = {
            slot0 = p:GetTrinket(0),
            slot1 = p:GetTrinket(1)
        },
        pills = {
            slot0 = p:GetPill(0),
            slot1 = p:GetPill(1)
        },
        count_item = p:GetCollectibleCount(),
    }
    return msg
end

function GetCharge(playerid)
    local p = Game():GetPlayer(playerid)
    local msg = {
        type = "charge-p"..playerid,
        hasActiveItem = (p:GetActiveItem() ~= -1),
        needsCharge = p:NeedsCharge(),
        slots = {p:GetActiveItem(0), p:GetActiveItem(1), p:GetActiveItem(2), p:GetActiveItem(3)}
    }
    return msg
end

function GetRoom()
    local l = Game():GetLevel()
    local r = l:GetCurrentRoom()
    local d = l:GetCurrentRoomDesc()
    local msg = {
        type = "room-status",
        level = l:GetAbsoluteStage(),
        room_idx = l:GetCurrentRoomIndex(),
        room_visited = d.VisitedCount,
        room_idx_list = d.ListIndex,
        room_idx_grid = d.GridIndex,
        room_idx_safegrid = d.SafeGridIndex,
        room_awardseed = d.AwardSeed,
        room_cleared = d.Clear,
        room_challengedone = d.ChallengeDone,
        room_display = d.DisplayFlags,
        room_haswater = d.HasWater,
        room_noreward = d.NoReward,
        room_pits = d.PitsCount,
        room_poop = d.PoopCount,
        room_plates = d.PressurePlatesTriggered,
        room_sacrificedone = d.SacrificeDone,
        room_shopdiscountidx = d.ShopItemDiscountIdx,
        room_shopitemidx = d.ShopItemIdx,
        room_miniboss = d.SurpriseMiniboss,
        room_count_boss = r:GetAliveBossesCount(),
        room_count_enem = r:GetAliveEnemiesCount(),
        room_devil = r:GetDevilRoomChance(),
        room_delirium = r:GetDeliriumDistance(),
        room_dungeonrock = r:GetDungeonRockIdx(),
        room_redheart_damage = r:GetRedHeartDamage(),
        room_shape = r:GetRoomShape(),
        room_shoplevel = r:GetShopLevel(),
        room_spawnseed = r:GetSpawnSeed(),
        room_taintedrock = r:GetTintedRockIdx(),
        room_type = r:GetType(),
        room_firstblood = r:IsFirstEnemyDead()
    }
    return msg
end

function GetLevel()
    local l = Game():GetLevel()
    local function hasRoom(t)
        local rng = RNG()
        local idx1 = Game():GetLevel():QueryRoomTypeIndex(t, false, rng)
        rng:Next()
        local idx2 = Game():GetLevel():QueryRoomTypeIndex(t, false, rng)
        rng:Next()
        local idx3 = Game():GetLevel():QueryRoomTypeIndex(t, false, rng)
        return (idx1 ~= -1) and (idx1 == idx2) and (idx1 == idx3)
    end
    local data = {
        type = "level-status",
        level_stage = (l:GetAbsoluteStage()),
        level_angel = (l:GetAngelRoomChance()),
        level_planetarium = (l:GetPlanetariumChance()),
        level_cursename = (l:GetCurseName()),
        level_curses = (l:GetCurses()),
        level_dungeon_seed = (l:GetDungeonPlacementSeed()),
        level_name = (l:GetName()),
        level_room_count = (l:GetRoomCount()),
        level_startroom_idx = (l:GetStartingRoomIndex()),
        level_has_bosschal = (l:HasBossChallenge()),
        level_is_alt = (l:IsAltStage()),
        level_nextstage = (l:IsNextStageAvailable()),
        level_dungeon_returnidx = (l.DungeonReturnRoomIndex),
        level_has_shop = hasRoom(RoomType.ROOM_SHOP),
        level_has_treasure = hasRoom(RoomType.ROOM_TREASURE),
        level_has_secret = hasRoom(RoomType.ROOM_SECRET),
        level_has_angel = hasRoom(RoomType.ROOM_ANGEL),
        level_has_devil = hasRoom(RoomType.ROOM_DEVIL),
        level_has_supersecret = hasRoom(RoomType.ROOM_SUPERSECRET),
        level_has_arcade = hasRoom(RoomType.ROOM_ARCADE),
        level_has_sacrifice = hasRoom(RoomType.ROOM_SACRIFICE),
        level_has_curse = hasRoom(RoomType.ROOM_CURSE),
        level_has_challenge = hasRoom(RoomType.ROOM_CHALLENGE),
        level_has_library = hasRoom(RoomType.ROOM_LIBRARY),
        level_has_dungeon = hasRoom(RoomType.ROOM_DUNGEON),
        level_has_isaacs = hasRoom(RoomType.ROOM_ISAACS),
        level_has_barren = hasRoom(RoomType.ROOM_BARREN),
        level_has_dice = hasRoom(RoomType.ROOM_DICE),
        level_has_error = hasRoom(RoomType.ROOM_ERROR),
        level_has_blackmarket = hasRoom(RoomType.ROOM_BLACK_MARKET),
        level_has_bossrush = hasRoom(RoomType.ROOM_BOSSRUSH),
        level_has_miniboss = hasRoom(RoomType.ROOM_MINIBOSS),
        level_has_chest = hasRoom(RoomType.ROOM_CHEST),
        level_has_greedexit = hasRoom(RoomType.ROOM_GREED_EXIT),
        level_has_teleporter = hasRoom(RoomType.ROOM_TELEPORTER),
        level_has_teleporterexit = hasRoom(RoomType.ROOM_TELEPORTER_EXIT),
        level_has_ultrasecret = hasRoom(RoomType.ROOM_ULTRASECRET),
        pillz = PillEffects()
    }
    if REPENTANCE then
        data.level_has_planetarium = hasRoom(RoomType.ROOM_PLANETARIUM)
      end

    return data
end
