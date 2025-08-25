-- Only for hunter
local _, classID = UnitClass("player")
if classID == "HUNTER" then
    local T              = H2E_LIB
    -- Assign the locale table to a local variable for easy access
    local L              = H2E_Locale
    local LAST_NO_THROW  = 0
    local TARGET         = "target"
    local MOUSE_OVER     = "mouseover"
    local PET_TARGET     = "pettarget"
    local PLAYER         = "player"
    local LOW_RATIO      = 0.2

    local changeToThrown = function()
        local index = 0
        for i = 1, 16 do
            link = GetContainerItemLink(0, i)
            if T.IsItemThrownWeapon(link) then
                index = i
                break
            end
        end
        if index > 0 then
            UseContainerItem(0, index)
        else
            LAST_NO_THROW = GetTime()
        end
    end;

    -- Change to Range Weapon when leave combat
    local changeToRange = function()
        local index = 0
        for i = 1, 16 do
            link = GetContainerItemLink(0, i)
            if T.IsItemRangedWeapon(link) then
                index = i
                break
            end
        end
        if index > 0 then
            UseContainerItem(0, index)
        end
    end;

    -- Pet will attack the target that attack self
    T.SaveMe = function()
        local _, originalGUID = UnitExists(TARGET)
        if UnitExists(MOUSE_OVER) then
            TargetUnit(MOUSE_OVER)
            PetAttack()
        else
            for i=1,16 do
                TargetNearestEnemy();
                if UnitIsUnit(PLAYER, TARGET .. TARGET) then
                    PetAttack()
                    break
                end
                local _, guid = UnitExists(TARGET)
                if guid == originalGUID then
                    return
                end
            end
        end
        -- target the original target
        if originalGUID then
            for i=1,16 do
                TargetNearestEnemy();
                local _, guid = UnitExists(TARGET)
                if guid == originalGUID then
                    break
                end
            end
        end
    end;

    -- Pet Attack, if not in full team, set pet to defensive mode
    T.PetAttack = function()
        if not PetHasActionBar() then
            T.CastSpellByName(L.CALL_PET)
        end
        PetAttack()
        if not UnitExists("party4") then
            PetDefensiveMode()
        end
    end;

    -- Range Attack Sequence: Hunter's Mark -> Auto Shot and PetAttack -> Throw or Arcane Shot
    -- Melee Attack Sequence: Auto Attack and PetAttack -> Mongoose Bite
    -- Wing Clip if target's target is self or nil
    T.Attack = function()
        if not UnitExists(TARGET) and UnitExists(PET_TARGET) then
            AssistUnit("pet")
        end
        if UnitExists(TARGET) and (not UnitExists(PET_TARGET) or UnitIsUnit(PLAYER, TARGET .. TARGET)) then
            T.PetAttack()
        end
        -- change to range weapon if distance more than 28 yards
        if UnitExists(TARGET) and not CheckInteractDistance(TARGET, 4) and T.IsThrownEquipped() then
            changeToRange()
        end
        -- close commbat
        if CheckInteractDistance(TARGET, 3) then
            if CURRENT_ACTIONBAR_PAGE ~= 2 then
                CURRENT_ACTIONBAR_PAGE = 2
                ChangeActionBarPage()
            end
            T.CastSpellByName(L.Raptor_STRIKE, LOW_RATIO)
            if not IsAttackAction(13) then
                -- toggle auto attack
                AttackTarget(TARGET)
            end
            if not T.WOLF then
                T.CastSpellByName(L.ASPECT_WOLF)
            end
            T.CastSpellByName(L.MONGOOSE_BITE, LOW_RATIO)
            if not T.TARGET_WING_CLIP then
                T.CastSpellByName(L.WING_CLIP)
            end
        -- range combat
        else
            if CURRENT_ACTIONBAR_PAGE ~= 1 then
                CURRENT_ACTIONBAR_PAGE = 1
                ChangeActionBarPage()
            end
            local mark = T.TARGET_HUNTER_MARK
            if not mark and UnitExists(TARGET) then
                T.CastSpellByName(L.HUNTER_MARK)
            end
            -- troggle auto shot
            if mark and not IsAutoRepeatAction(1) then
                UseAction(1)
            end
            -- change to aspect of the hawk
            if not T.HAWK then
                T.CastSpellByName(L.ASPECT_HAWK)
            end
            if mark then
                if T.IsThrownEquipped() then
                    -- throwing weapon durability is 0
                    if GetInventoryItemBroken(PLAYER, 18) then
                        -- use throwing  weapon in the main bag
                        changeToThrown()
                    end
                    T.CastSpellByName(L.THROW)
                    if not T.TARGET_STING and T.GetSpellCooldown(T.SPELL_IDS[L.THROW]) > 0 then
                        T.CastSpellByName(L.MULTI_SHOT, 1) -- always rank 1
                    end
                else
                    if not IsUsableAction(1) then
                        changeToThrown()
                    end
                    if T.GetSpellCooldown(T.SPELL_IDS[L.ARCANE_SHOT]) == 0 then
                        T.CastSpellByName(L.ARCANE_SHOT, LOW_RATIO)
                    end
                end
            end
        end
    end;

    local frame = CreateFrame("Frame");
    -- Register for the event that signals a unit's aura has changed.
    frame:RegisterEvent("UNIT_AURA");
    frame:RegisterEvent("VARIABLES_LOADED");
    frame:RegisterEvent("PLAYER_TARGET_CHANGED");
    -- This is the function that runs every time the event is triggered.
    frame:SetScript("OnEvent", function()
        if event ==  "VARIABLES_LOADED" or arg1 == PLAYER then
            -- Buff
            T.MONKEY, T.HAWK, T.WOLF, T.CHEETAH
                = T.HasBuffs(PLAYER, "Monkey", "RavenForm", "DireWolf", "JungleTiger");
        end
        if event == "PLAYER_TARGET_CHANGED" or arg1 == TARGET then
            T.TARGET_HUNTER_MARK, T.TARGET_SERPENT_STING, T.TARGET_SCORPID_STING, T.TARGET_WING_CLIP
                = T.HasDebuffs(TARGET, "SniperShot", "Quickshot", "CriticalShot", "Rogue_Trip")
            T.TARGET_STING = T.TARGET_SCORPID_STING or T.TARGET_SERPENT_STING
        end
    end);

    local changeWeapon = CreateFrame("Frame");
    changeWeapon:RegisterEvent("PLAYER_REGEN_ENABLED");
    changeWeapon:SetScript("OnEvent", function()
        if T.IsThrownEquipped() and IsUsableAction(1) then
            changeToRange()
        end
    end);


    -- Equip the throwing weapon from the main bag after Auto Shot, when Arcane Shot is used.
    local autoShot = CreateFrame("Frame");
    autoShot:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
    autoShot:SetScript("OnEvent", function()
        if T.StringBeginsWith(arg1, L.YOUR_AUTO_SHOT) then
            -- don't try to use Throwing weapon in 60 seconds if can't find a throwing weapon is main bag
            if GetTime() - LAST_NO_THROW < 60 then
                return
            end
            -- change to throwing weapon after arcane shot
            if not T.IsThrownEquipped()
            and (not IsUsableAction(1) or T.GetSpellCooldown(T.SPELL_IDS[L.ARCANE_SHOT]) > 1.5)
            and CheckInteractDistance(TARGET, 4) then
                changeToThrown()
            end
        end
        -- change to range weapon if distance more than 28 yards
        if not CheckInteractDistance(TARGET, 4) and T.IsThrownEquipped() then
            changeToRange()
        end
        -- change to range weapon in close combat
        if CheckInteractDistance(TARGET, 3) and T.IsThrownEquipped() and T.GetSpellCooldown(T.SPELL_IDS[L.SERPENT_STING]) > 1 then
            changeToRange()
        end
    end);

    -- Create a hidden frame to handle the timer
    local timerFrame = CreateFrame("Frame")
    -- Define variables for our timer
    local DELAY_TIME = 3 -- The delay in seconds
    local currentTimer = 0

    -- Set a script that runs every frame
    timerFrame:SetScript("OnUpdate", function()
        -- Add the time since the last frame to our timer
        currentTimer = currentTimer + arg1

        -- Set Auto Shot and Attack to action bar, stop timer is more than 3 seconds
        if currentTimer >= DELAY_TIME then
            currentTimer = 0
            -- Stop the OnUpdate script by hiding the frame
            timerFrame:Hide()
            return
        end
        if T.SPELL_IDS[L.AUTO_SHOT] and T.SPELL_IDS[L.ATTACK] then
            PickupSpell(T.SPELL_IDS[L.AUTO_SHOT], BOOKTYPE_SPELL)
            PlaceAction(1)
            PickupSpell(T.SPELL_IDS[L.ATTACK], BOOKTYPE_SPELL)
            PlaceAction(13)
            -- Reset the timer
            currentTimer = 0
            -- Stop the OnUpdate script by hiding the frame
            timerFrame:Hide()
            return
        end

    end)

    local createMacros = CreateFrame("Frame");
    createMacros:RegisterEvent("PLAYER_LOGIN");
    createMacros:SetScript("OnEvent", function()
        timerFrame:Show() -- start timer
        T.CreateMicro("H2E_Attack", 45, "/run H2E_LIB.Attack()");
        T.CreateMicro("H2E_Save", 4, "/run H2E_LIB.SaveMe()");
        T.CreateMicro("H2E_Assist", 7, "/run H2E_LIB.Assist()");
    end);
end