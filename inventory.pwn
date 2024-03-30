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
 * # External
 */

stock bool:AddItemToInventory(playerid, itemid, amount) {
    if (!IsPlayerConnected(playerid)) {
        return false;
    }

    return AddItemToContainer(gContainerID[playerid], itemid, amount);
}

stock bool:RemoveItemFromInventory(playerid, itemid, amount) {
    if (!IsPlayerConnected(playerid)) {
        return false;
    }

    return RemoveItemFromContainer(gContainerID[playerid], itemid, amount);
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
