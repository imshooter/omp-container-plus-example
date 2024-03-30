/**
 * # Header
 */

#if !defined MAX_INVENTORY_SLOTS
    #define MAX_INVENTORY_SLOTS (128)
#endif

static
    gContainerID[MAX_PLAYERS] = { -1, ... }
;

/**
 * # Functions
 */

forward bool:AddItemToInventory(playerid, itemid, amount, bool:call = true);
forward bool:RemoveItemFromInventory(playerid, slot, bool:call = true);
forward bool:GetInventorySlotData(playerid, slot, &itemid, &amount);

/**
 * # Calls
 */

forward OnItemAddToInventory(playerid, slot, itemid, amount);
forward OnItemRemoveFromInventory(playerid, slot, itemid, amount);

/**
 * # External
 */

stock bool:AddItemToInventory(playerid, itemid, amount, bool:call = true) {
    if (!IsPlayerConnected(playerid)) {
        return false;
    }

    new const
        slot = AddItemToContainer(gContainerID[playerid], itemid, amount)
    ;

    if (slot == -1) {
        return false;
    }

    if (call) {
        CallLocalFunction("OnItemAddToInventory", "iiii", playerid, slot, itemid, amount);
    }

    return true;
}

stock bool:RemoveItemFromInventory(playerid, slot, bool:call = true) {
    new
        itemid,
        amount
    ;

    if (!GetInventorySlotData(playerid, slot, itemid, amount)) {
        return false;
    }

    RemoveItemFromContainer(gContainerID[playerid], slot);

    if (call) {
        CallLocalFunction("OnItemRemoveFromInventory", "iiii", playerid, slot, itemid, slot);
    }

    return true;
}

stock bool:GetInventorySlotData(playerid, slot, &itemid, &amount) {
    if (!IsPlayerConnected(playerid)) {
        return false;
    }

    return GetContainerSlotData(gContainerID[playerid], slot, itemid, amount);
}

/**
 * # Calls
 */

public OnPlayerConnect(playerid) {
    gContainerID[playerid] = CreateContainer("Inventory", MAX_INVENTORY_SLOTS);
    
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    #pragma unused reason
    
    DestroyContainer(gContainerID[playerid]);
    gContainerID[playerid] = -1;
    
    return 1;
}
