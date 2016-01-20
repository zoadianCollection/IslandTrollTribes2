var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var hero = Players.GetPlayerHeroEntityIndex( LocalPlayerID )
var ingredients = Root.ingredients
var table = Root.table
var itemResult = Root.itemname
var aliasTable = CustomNetTables.GetTableValue( "crafting", "Alias" )

for (var i = 0; i < ingredients.length; i++) {
    MakeItemPanel(ingredients[i], ingredients.length, i)
};

var equal = $.CreatePanel("Label", Root, "EqualSign")
equal.text = "="

// Resulting from craft
var resultPanel = MakeItemPanel(itemResult, 0)

CheckInventory()

function MakeItemPanel(name, elements, num) {
    var itemPanel = $.CreatePanel("Panel", Root, name)
    itemPanel.itemname = name
    itemPanel.elements = elements

    itemPanel.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_item.xml", false, false);
    
    return itemPanel

    /*if (elements>0)
    {
        var spacing = 70/elements
        itemPanel.style["width"] = spacing+"%"
    }*/
}

function CheckInventory()
{
    // Build an array of items in inventory 
    var itemsOnInventory = []

    for (var i = 0; i < 6; i++) {
        var item = Entities.GetItemInSlot( hero, i )
        if (item)
        {
            var item_name = Abilities.GetAbilityName(item)
            if (item_name != "item_slot_locked")
                itemsOnInventory.push(item_name)
        }
    };

    if (Root.visible)
    {
        var meetsAllRequirements = true
        var childNum = Root.GetChildCount()
        for (var i = 0; i < childNum; i++) {
            var child = Root.GetChild(i)
            if (child.itemname !== undefined && child.itemname != itemResult)
            {
                var itemIndex = FindItemInArray(child.itemname, itemsOnInventory)
                if (itemIndex > -1)
                {
                    itemsOnInventory.splice(itemIndex, 1)
                    AddGlow(child)
                }
                else
                {
                    meetsAllRequirements = false
                    RemoveGlow(child)
                }
            }
        };
    }

    if (meetsAllRequirements)
        GlowCraft(resultPanel)
    else
        RemoveGlow(resultPanel)

    $.Schedule(1, CheckInventory)
}

// Search for an item by name taking alias into account
function FindItemInArray(itemName, itemList) {
    for (var index in itemList)
    {
        if (itemList[index] == itemName)
        {
            return index
        }
        else if (MatchesAlias(itemName, itemList[index]))
        {
            return index
        }
    }
    return -1
}

function MatchesAlias( aliasName, targetItemName ) {
    if (aliasName.indexOf("any_") > -1)
    {
        for (var itemName in aliasTable[aliasName])
        {
            if (itemName==targetItemName)
            {
                return true
            }
        }
    }
    return false
}

function AddGlow(panel) {
    panel.style['box-shadow'] = "0px 0px 100% gold";
}

function RemoveGlow(panel) {
    panel.style['box-shadow'] = "0px 0px 0%";
}

function GlowCraft(panel) {
    panel.style['box-shadow'] = "0px 0px 100% green";
}