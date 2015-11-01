
function InventoryCheck( unit )
    local recipeTable = GameRules.Crafting['Recipes']

    for recipeName,recipeIngredients in pairs(recipeTable) do 
        
        -- If the inventory contains enough of the ingredient items defined in the recipeTable, combine and clear
        local craftingItems = CanCombine(unit, recipeName)
        if craftingItems then
            match = recipeName
            -- Clear the inventory items returned by the CanCombine aux
            ClearItems(craftingItems, recipeIngredients)   

            -- Create the resulting item
            unit:AddItem(CreateItem(recipeName, nil, nil))

            break
        end
    end
end

function CanCombine( unit, recipeName )
    local requirements = GameRules.Crafting['Recipes'][recipeName]

    local result = {}
    for itemName,num in pairs(requirements) do
        local items = HasEnoughInInventory(unit, itemName, num)
        if items then
            table.insert(result, items)
        else
            return false
        end
    end

    -- All the requirements passed, return the result to combine
    print("Can Combine "..recipeName)
    return result
end

-- Counts stack charges and returns the items involved in 
-- If a charge goes over the max required items, the item removal will have to only remove the precise amount of charges instead of the full item
function HasEnoughInInventory( unit, itemName, num )
    local bEnough = false

    local items = {}
    local currentNum = 0
    for i=0,5 do
        local item = unit:GetItemInSlot(i)
        if item then
            local thisItemName = item:GetAbilityName()
            if thisItemName ~= "item_slot_locked" then
                if thisItemName == itemName then
                    if item:GetCurrentCharges() == 0 then
                        currentNum = currentNum + 1
                    else
                        currentNum = currentNum + item:GetCurrentCharges()
                    end
                    table.insert(items, item)

                elseif string.match(itemName, "any_") and MatchesAlias(itemName, thisItemName) then
                    currentNum = currentNum + 1
                    table.insert(items, item)
                end
            end
        end
    end

    if currentNum >= num then
        return items
    else
        return false
    end
end

-- Returns whether the itemName can be matched to any of the alias
function MatchesAlias( aliasName, itemName )  
    local alias = string.gsub(aliasName, "any_", "")
    local aliasTable = GameRules.Crafting['Alias'][alias]
    
    for k,v in pairs(aliasTable) do
        if k==itemName then
            return true
        end
    end
    return false
end

-- TODO: Handle stacks, never delete a full item if we pick more than the required count
function ClearItems( itemList, requirements )
    for k,v in pairs(itemList) do
        for kk,vv in pairs(v) do
            UTIL_Remove(vv)
        end
    end
end

function GetRandomAliasFor(aliasName)
    local alias = string.gsub(aliasName, "any_", "")
    local aliasTable = GameRules.Crafting['Alias'][alias]
    local random = RandomInt(1, 3)
    local count = 1
    for k,v in pairs(aliasTable) do
        if count == random then
            return k
        else
            count = count + 1
        end
    end
end







------------------------------------------------

--[[function InventoryCheck(playerID)
    -- print("Inv testing player " .. playerID)
    -- Lets find the hero we want to work with
    local player = PlayerInstanceFromIndex(playerID)
    local hero =   player:GetAssignedHero()
    if hero == nil then
        --print("hero " .. playerID .. " doesn't exist!")
    else
        CraftItems(hero, TROLL_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        --craftinghelper.lua explains how to format the tables
        --tables are contained in recipe_list.lua
    end
end

recipeTable is a table of tables and should be in the format of:
    {
        {"resulting_item1", {"material_1", "material_2", "material_3"}},
        {"resulting_item2", {"material_4", "material_5"}}
    }

    aliasTable is used when multiple different items can all be substituted for something
    Also a table of tables, each entry should include a resulting name and what materials should be replaced with that name

    {
        {"resulting_name", {"material_1", "material_2", "material_3"}}
    }

    Will replace any "material_1", "material_2", or "material_3" with "resulting_name"

function CraftItems(unit, recipeTable, aliasTable)
    if aliasTable == nil then
        aliasTable = {}
    end
    local unitInventoryList = {}
    for j=0,5,1 do
        if unit:GetItemInSlot(j) ~= nil then
            local itemInSlot = unit:GetItemInSlot(j):GetName()
            --deal with item aliases
            for k,v in pairs(aliasTable) do
                for _,alias in pairs(v[2]) do
                    if string.find(itemInSlot, alias) then
                        itemInSlot = v[1]
                    end
                end
            end
            unitInventoryList[j] = itemInSlot
        else
            unitInventoryList[j] = "empty_slot_" .. j
        end
    end

    for k,v in pairs(recipeTable) do
        subtable =  table_slice(unitInventoryList,0,(#v[2])-1)
        if CompareTables(v[2], subtable) then
            print("match", v[1])
            for slot,itemName in pairs(subtable) do
                local removeMe = unit:GetItemInSlot(slot-1)
                unit:RemoveItem(removeMe)
            end
            local newItem = CreateItem(v[1], unit, unit)
            unit:AddItem(newItem)
        end
    end
end

function table_slice (values,i1,i2)
    local res = {}
    local n = #values
    -- default values for range
    i1 = i1 or 1
    i2 = i2 or n

    if i2 < 0 then
        i2 = n + i2 + 1
    elseif i2 > n then
        i2 = n
    end

    if i1 < 0 or i1 > n then
        return {}
    end

    local k = 1
    for i = i1,i2 do
        res[k] = values[i]
        k = k + 1
    end

    return res
end

--Compares two tables to see if they have the same values
function CompareTables(table1, table2)
    --print("Comparing tables")
    if type(table1) ~= "table" or type(table2) ~= "table" then
        return false
    end

    if #table1 ~= #table1 then
        return false
    end
    
    for key,value in pairs(table1) do
        --print(key, table1[key], table2[key])
        if table2[key] == nil then
            return false
        elseif table2[key] ~= table1[key] then
            return false
        end
    end
    
    --print("check other table, just in case")    

    for key,value in pairs(table2) do
        --print(key, table2[key], table1[key])
        if table1[key] == nil then
            return false
        elseif table1[key] ~= table2[key] then
            return false
        end
    end
    
    --print("Match!")
    return true
end]]