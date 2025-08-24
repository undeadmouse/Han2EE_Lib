H2E_VERSION="1.0"
H2E_LIB      = {}
local T      = H2E_LIB
-- Assign the locale table to a local variable for easy access
local L      = H2E_Locale

local TARGET = "target"

-- set buff and debuff amount to 64
T.MAX_BUFF_NUM   = 64;
T.MAX_DEBUFF_NUM = 64;

-- use for cooldown api, spell is highest rank by default
T.SPELL_IDS = {}

-- regex match support, Copy from Compatibility.lua
if not string.match then
    local function getargs(s, e, ...)
        return unpack(arg)
    end
    function string.match(str, pattern)
        return getargs(string.find(str, pattern))
    end
end

-- Returns true if the string 'str' ends with the string 'suffix', otherwise false.
T.StringEndsWith = function(str, suffix)
    return string.sub(str, -string.len(suffix)) == suffix
end;

-- Returns true if the string 'str' begins with the string 'suffix', otherwise false.
T.StringBeginsWith = function(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

-- Calculates and returns the remaining cooldown time for a given action slot.
T.GetActionCooldown = function(slotID)
    local start, duration = GetActionCooldown(slotID);
    local currentTime = GetTime();

    if not start or start == 0 then
        return 0; -- No cooldown is active
    end

    local remaining = (start + duration) - currentTime;

    if remaining > 0 then
        return remaining;
    else
        return 0; -- Cooldown has finished
    end
end;

-- Calculates and returns the remaining cooldown time for a given spell ID.
T.GetSpellCooldown = function(spellID, bookType)
    local myBookType = BOOKTYPE_SPELL
    if bookType then
        myBookType = bookType
    end
    local start, duration = GetSpellCooldown(spellID,myBookType)
    local currentTime = GetTime();

    if not start or start == 0 then
        return 0; -- No cooldown is active
    end

    local remaining = (start + duration) - currentTime;

    if remaining > 0 then
        return remaining;
    else
        return 0; -- Cooldown has finished
    end
end;

-- Check if Item is Ranged Weapon
T.IsItemRangedWeapon = function(item)
    if not item then
        return false;
    end
    
    local itemID = item
    if type(item) == "string" then
        itemID = string.match(item, "|Hitem:(%d+)");
    end
    local itemName, itemLink, itemRarity, itemLevel, itemType, itemSubtype= GetItemInfo(itemID)
    if itemSubtype == L.WEAPON_BOWS or itemSubtype == L.WEAPON_GUNS or itemSubtype == L.WEAPON_CROSSBOWS then
        return true
    end
    
    return false
end;

-- Check if Item is Thrown Weapon
T.IsItemThrownWeapon = function(item)
    if not item then
        return false;
    end
    
    local itemID = item
    if type(item) == "string" then
        itemID = string.match(item, "|Hitem:(%d+)");
    end
    local itemName, itemLink, itemRarity, itemLevel, itemType, itemSubtype= GetItemInfo(itemID)
    if itemSubtype == L.WEAPON_THROWN then
        return true
    end
    return false
end;

-- Check if the item in the ranged weapon slot is a throwing weapon.
T.IsThrownEquipped = function()
    local link = GetInventoryItemLink("player", 18);
    return T.IsItemThrownWeapon(link)
end;

T.ListBuffs = function(target)
    for i = 1, T.MAX_BUFF_NUM do
        local buff = UnitBuff(target, i)
        if not buff then
            break;
        end
        DEFAULT_CHAT_FRAME:AddMessage(buff)
    end
end;

T.ListDebuffs = function(target)
    for i = 1, T.MAX_BUFF_NUM do
        local debuff = UnitDebuff(target, i)
        if not debuff then
            break;
        end
        DEFAULT_CHAT_FRAME:AddMessage(debuff)
    end
end;

T.HasBuffs = function(target, buffName1, buffName2, buffName3, buffName4, buffName5)
    local res1, res2, res3, res4, res5
    local strEndsWith = T.StringEndsWith
    for i = 1, T.MAX_BUFF_NUM do
        local buff = UnitBuff(target, i)
        if not buff then
            break;
        end
    
        res1 = res1 or (buffName1 and strEndsWith(buff, buffName1))
        res2 = res2 or (buffName2 and strEndsWith(buff, buffName2));
        res3 = res3 or (buffName3 and strEndsWith(buff, buffName3));
        res4 = res4 or (buffName4 and strEndsWith(buff, buffName4));
        res5 = res5 or (buffName5 and strEndsWith(buff, buffName5));
    end
    return res1, res2, res3, res4, res5
end;

T.SomeBuffs = function(target, buffName1, buffName2, buffName3, buffName4, buffName5)
    local res1, res2, res3, res4, res5
    local strEndsWith = T.StringEndsWith
    for i = 1, T.MAX_BUFF_NUM do
        local buff = UnitBuff(target, i)
        if not buff then
            break;
        end
    
        res1 = res1 or (buffName1 and strEndsWith(buff, buffName1))
        res2 = res2 or (buffName2 and strEndsWith(buff, buffName2));
        res3 = res3 or (buffName3 and strEndsWith(buff, buffName3));
        res4 = res4 or (buffName4 and strEndsWith(buff, buffName4));
        res5 = res5 or (buffName5 and strEndsWith(buff, buffName5));
    end
    return res1 or res2 or res3 or res4 or res5
end;

T.AllBuffs = function(target, buffName1, buffName2, buffName3, buffName4, buffName5)
    local res1, res2, res3, res4, res5
    local strEndsWith = T.StringEndsWith
    for i = 1, T.MAX_BUFF_NUM do
        local buff = UnitBuff(target, i)
        if not buff then
            break;
        end
    
        res1 = res1 or (buffName1 and strEndsWith(buff, buffName1))
        res2 = res2 or (buffName2 and strEndsWith(buff, buffName2));
        res3 = res3 or (buffName3 and strEndsWith(buff, buffName3));
        res4 = res4 or (buffName4 and strEndsWith(buff, buffName4));
        res5 = res5 or (buffName5 and strEndsWith(buff, buffName5));
    end
    return (not buffName1 or res1) and (not buffName2 or res2) and (not buffName3 or res3) and (not buffName4 or res4) and (not buffName5 or res5)
end;

T.HasDebuffs = function(target, debuffName1, debuffName2, debuffName3, debuffName4, debuffName5)
    local res1, res2, res3, res4, res5
    local strEndsWith = T.StringEndsWith
    for i = 1, T.MAX_DEBUFF_NUM do
        local debuff = UnitDebuff(target, i)
        if not debuff then
            break;
        end
    
        res1 = res1 or (debuffName1 and strEndsWith(debuff, debuffName1))
        res2 = res2 or (debuffName2 and strEndsWith(debuff, debuffName2));
        res3 = res3 or (debuffName3 and strEndsWith(debuff, debuffName3));
        res4 = res4 or (debuffName4 and strEndsWith(debuff, debuffName4));
        res5 = res5 or (debuffName5 and strEndsWith(debuff, debuffName5));
    end
    return res1, res2, res3, res4, res5
end;

T.SomeDebuffs = function(target, debuffName1, debuffName2, debuffName3, debuffName4, debuffName5)
    local res1, res2, res3, res4, res5
    local strEndsWith = T.StringEndsWith
    for i = 1, T.MAX_DEBUFF_NUM do
        local debuff = UnitDebuff(target, i)
        if not debuff then
            break;
        end
    
        res1 = res1 or (debuffName1 and strEndsWith(debuff, debuffName1))
        res2 = res2 or (debuffName2 and strEndsWith(debuff, debuffName2));
        res3 = res3 or (debuffName3 and strEndsWith(debuff, debuffName3));
        res4 = res4 or (debuffName4 and strEndsWith(debuff, debuffName4));
        res5 = res5 or (debuffName5 and strEndsWith(debuff, debuffName5));
    end
    return res1 or res2 or res3 or res4 or res5
end;

T.SomeDebuffs = function(target, debuffName1, debuffName2, debuffName3, debuffName4, debuffName5)
    local res1, res2, res3, res4, res5
    local strEndsWith = T.StringEndsWith
    for i = 1, T.MAX_DEBUFF_NUM do
        local debuff = UnitDebuff(target, i)
        if not debuff then
            break;
        end
    
        res1 = res1 or (debuffName1 and strEndsWith(debuff, debuffName1))
        res2 = res2 or (debuffName2 and strEndsWith(debuff, debuffName2));
        res3 = res3 or (debuffName3 and strEndsWith(debuff, debuffName3));
        res4 = res4 or (debuffName4 and strEndsWith(debuff, debuffName4));
        res5 = res5 or (debuffName5 and strEndsWith(debuff, debuffName5));
    end
    return res1 and res2 and res3 and res4 or res5
end;

T.AllDebuffs = function(target, debuffName1, debuffName2, debuffName3, debuffName4, debuffName5)
    local res1, res2, res3, res4, res5
    local strEndsWith = T.StringEndsWith
    for i = 1, T.MAX_DEBUFF_NUM do
        local debuff = UnitDebuff(target, i)
        if not debuff then
            break;
        end
    
        res1 = res1 or (debuffName1 and strEndsWith(debuff, debuffName1))
        res2 = res2 or (debuffName2 and strEndsWith(debuff, debuffName2));
        res3 = res3 or (debuffName3 and strEndsWith(debuff, debuffName3));
        res4 = res4 or (debuffName4 and strEndsWith(debuff, debuffName4));
        res5 = res5 or (debuffName5 and strEndsWith(debuff, debuffName5));
    end
    return (not debuffName1 or res1) and (not debuffName2 or res2) and (not debuffName3 or res3) and (not debuffName4 or res4) or (not debuffName5 or res5)
end;

T.CreateMicro = function(macroName, macroIcon, macroBody)
    local macroExists = false
    
    -- Loop through all existing macros to see if ours already exists
    for i = 1, 36 do
        local name = GetMacroInfo(i)
        if name == macroName then
            macroExists = true
            break
        end
    end
    
    -- If the macro does not exist, create it
    if not macroExists then
        CreateMacro(macroName, macroIcon, macroBody, 1, 1)
    end
end;

-- Assit Main Tank in dungeon
T.Assist = function()
    local _, firstTarget = UnitExists(TARGET)
    local foundTarget = firstTarget
    for i = 1, 16 do
        TargetNearestEnemy()
        local _, guid = UnitExists(TARGET)
        local raidIdx = GetRaidTargetIndex(TARGET)
        if UnitPlayerOrPetInParty(TARGET .. TARGET) and UnitIsUnit(TARGET, TARGET .. TARGET .. TARGET) then
            foundTarget = guid
        end
        --  Red "X" Cross is 7, White Skull is 8
        if raidIdx == 7 or raidIdx == 8 then
            foundTarget = guid
            break;
        end
        if guid == firstTarget then
            break
        end
    end
    ClearTarget()
    if not foundTarget then
        return
    end
    for i = 1, 16 do
        TargetNearestEnemy()
        local _, guid = UnitExists(TARGET)
        if guid == foundTarget then
            break
        end
    end
end;

-- Delete the trash item less than price
T.DeleteLessItems = function(price)
    -- SellValues Addons exists
    if (not SellValues) then
        return
    end

    -- ignore the Main Bag
    for bag = 1, 4 do
        if (GetContainerNumSlots(bag) > 0) then
            for slot = 1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, slot)
                if itemLink then
                    -- check if item is gray
                    if strfind(itemLink, "ff9d9d9d") then
                        local itemID = string.match(itemLink, "item:(%d+):")
                        local itemKey = "item:" .. itemID

                        local sellPrice = SellValues[itemKey]
                        
                        -- delete the item if sell price less the given price
                        if sellPrice and sellPrice < price then
                            PickupContainerItem(bag, slot);
                            DeleteCursorItem();
                        end
                    end
                end
            end
        end
    end
end;

-- Delete the trash item less than price
T.DeleteWhiteItems = function(price)
    -- SellValues Addons exists
    if (not SellValues) then
        return
    end

    -- ignore the Main Bag
    for bag = 1, 4 do
        if (GetContainerNumSlots(bag) > 0) then
            for slot = 1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, slot)
                if itemLink then
                    -- check if item is gray
                    if strfind(itemLink, "ffffffff") then
                        local itemID = string.match(itemLink, "item:(%d+):")
                        local itemKey = "item:" .. itemID

                        local sellPrice = SellValues[itemKey]
                        
                        -- delete the item if sell price less the given price
                        if sellPrice and sellPrice < price then
                            PickupContainerItem(bag, slot);
                            DeleteCursorItem();
                        end
                    end
                end
            end
        end
    end
end;

-- CastSpellByName will check the cooldown
-- argument player's mana is less than argument mana, use rank 1 spell 
T.CastSpellByName = function(spellName, mana)
    if not spellName then
        return
    end
    local spellID = T.SPELL_IDS[spellName]
    if (not spellID) then
        return
    end
    if mana and UnitMana("player") < mana * UnitManaMax("player") and T.SPELL_IDS[spellName .. L.RANK_ONE] then
        spellID = T.SPELL_IDS[spellName .. L.RANK_ONE]
    end
    if T.GetSpellCooldown(spellID) == 0 then
        CastSpell(spellID, "spell") 
    end
end;

local selfHitOrMisses = CreateFrame("Frame");
selfHitOrMisses:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
selfHitOrMisses:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES");
selfHitOrMisses:SetScript("OnEvent", function()
    -- print(arg1)
end);

local changeInv = CreateFrame("Frame");
changeInv:RegisterEvent("UNIT_INVENTORY_CHANGED");
changeInv:SetScript("OnEvent", function()
end);

local loadSpellIDs = CreateFrame("Frame");
loadSpellIDs:RegisterEvent("LEARNED_SPELL_IN_TAB");
loadSpellIDs:RegisterEvent("PLAYER_LOGIN");
loadSpellIDs:SetScript("OnEvent", function()
    -- Get the total number of spellbook tabs
    local numTabs = GetNumSpellTabs()

    -- Iterate through each spellbook tab
    for tabIndex = 1, numTabs do
        -- Get the info for the current tab
        local _, _, offset, numSpells = GetSpellTabInfo(tabIndex)

        -- Iterate through each spell slot on this tab
        for i = 1, numSpells do
            local spellSlot = offset + i
            local spellName, rank = GetSpellName(spellSlot, BOOKTYPE_SPELL)

            -- Save the highest rank spell
            if spellName then
                T.SPELL_IDS[spellName] = spellSlot
            end
            -- Also save the rank 1 spell
            if spellName and rank == L.RANK_ONE then
                T.SPELL_IDS[spellName .. rank] = spellSlot
            end
        end
    end
end);