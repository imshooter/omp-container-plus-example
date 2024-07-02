#include <PawnPlus>

#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

#if !defined MAX_CONTAINERS
    #define MAX_CONTAINERS (Container:4096)
#endif

#if !defined MAX_CONTAINER_NAME
    #define MAX_CONTAINER_NAME (16)
#endif

#if !defined MAX_CONTAINER_SLOTS
    #define MAX_CONTAINER_SLOTS (128)
#endif

#define INVALID_CONTAINER_ID (Container:-1)

static enum E_CONTAINER_DATA {
    E_CONTAINER_NAME[MAX_CONTAINER_NAME + 1],
    Pool:E_CONTAINER_POOL
};

static
    gContainerData[MAX_CONTAINERS][E_CONTAINER_DATA]
;

static
    Container:gItemContainerID[MAX_ITEMS] = { INVALID_CONTAINER_ID, ... },
    gItemContainerSlotID[MAX_ITEMS] = { -1, ... }
;

const static
    CONTAINER_ITER_SIZE = _:MAX_CONTAINERS
;

new
    Iterator:Container<Container:CONTAINER_ITER_SIZE>
;

/**
 * # Functions
 */

forward Container:CreateContainer(const name[], size, bool:ordered = true);
forward bool:IsValidContainer(Container:containerid);
forward bool:DestroyContainer(Container:containerid);
forward bool:SetContainerName(Container:containerid, const name[]);
forward bool:GetContainerName(Container:containerid, name[], size = sizeof (name));
forward bool:SetContainerSize(Container:containerid, size);
forward GetContainerSize(Container:containerid);
forward GetContainerItemCount(Container:containerid);
forward AddItemToContainer(Container:containerid, Item:itemid, playerid = INVALID_PLAYER_ID, bool:call = true);
forward RemoveItemFromContainer(Container:containerid, index, playerid = INVALID_PLAYER_ID, bool:call = true);
forward bool:IsContainerFull(Container:containerid);
forward bool:IsContainerEmpty(Container:containerid);
forward bool:IsContainerSlotUsed(Container:containerid, index);
forward bool:GetContainerSlotItem(Container:containerid, index, &Item:itemid);
forward bool:GetItemContainerData(Item:itemid, &Container:containerid = INVALID_CONTAINER_ID, &index = -1);

/**
 * # Events
 */

forward OnItemAddToContainer(Container:containerid, Item:itemid, index, playerid);
forward OnItemRemoveFromContainer(Container:containerid, Item:itemid, index, playerid);

/**
 * # External
 */

stock Container:CreateContainer(const name[], size, bool:ordered = true) {
    if (!(1 <= size <= MAX_CONTAINER_SLOTS)) {
        return INVALID_CONTAINER_ID;
    }

    new const
        Container:id = Container:Iter_Alloc(Container)
    ;

    if (_:id == INVALID_ITERATOR_SLOT) {
        return INVALID_CONTAINER_ID;
    }

    strcopy(gContainerData[id][E_CONTAINER_NAME], name);
    gContainerData[id][E_CONTAINER_POOL] = pool_new(size, ordered);

    return id;
}

stock bool:IsValidContainer(Container:containerid) {
    return (0 <= _:containerid < CONTAINER_ITER_SIZE) && Iter_Contains(Container, containerid);
}

stock bool:DestroyContainer(Container:containerid) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    pool_delete(gContainerData[id][E_CONTAINER_POOL]);

    Iter_Remove(Container, containerid);

    return true;
}

stock bool:SetContainerName(Container:containerid, const name[]) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    strcopy(gContainerData[containerid][E_CONTAINER_NAME], name);

    return true;
}

stock bool:GetContainerName(Container:containerid, name[], size = sizeof (name)) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    strcopy(name, gContainerData[containerid][E_CONTAINER_NAME], size);

    return true;
}

stock bool:SetContainerSize(Container:containerid, size) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    pool_resize(gContainerData[containerid][E_CONTAINER_POOL], size);

    return true;
}

stock GetContainerSize(Container:containerid) {
    if (!IsValidContainer(containerid)) {
        return 0;
    }

    return pool_capacity(gContainerData[containerid][E_CONTAINER_POOL]);
}

stock GetContainerItemCount(Container:containerid) {
    if (!IsValidContainer(containerid)) {
        return 0;
    }

    return pool_size(gContainerData[id][E_CONTAINER_POOL]);
}

stock AddItemToContainer(Container:containerid, Item:itemid, playerid = INVALID_PLAYER_ID, bool:call = true) {
    if (!IsValidContainer(containerid)) {
        return 1;
    }

    if (!IsValidItem(itemid)) {
        return 2;
    }

    if (gItemContainerID[itemid] != INVALID_CONTAINER_ID) {
        return 3;
    }

    if (pool_size(gContainerData[containerid][E_CONTAINER_POOL]) >= pool_capacity(gContainerData[containerid][E_CONTAINER_POOL])) {
        return 4;
    }

    gItemContainerID[itemid] = containerid;
    gItemContainerSlotID[itemid] = pool_add(gContainerData[containerid][E_CONTAINER_POOL], _:itemid);

    if (call) {
        CallLocalFunction("OnItemAddToContainer", "iiii", _:containerid, _:itemid, gItemContainerSlotID[itemid], playerid);
    }

    return 0;
}

stock RemoveItemFromContainer(Container:containerid, index, playerid = INVALID_PLAYER_ID, bool:call = true) {
    if (!IsValidContainer(containerid)) {
        return 1;
    }

    new
        Item:itemid
    ;

    if (!GetContainerSlotItem(containerid, index, itemid)) {
        return 2;
    }

    gItemContainerID[itemid] = INVALID_CONTAINER_ID;
    gItemContainerSlotID[itemid] = -1;

    pool_remove(gContainerData[containerid][E_CONTAINER_POOL], index);

    if (call) {
        CallLocalFunction("OnItemRemoveFromContainer", "iiii", _:containerid, _:itemid, index, playerid);
    }

    return 0;
}

stock bool:IsContainerFull(Container:containerid) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    return (pool_size(gContainerData[containerid][E_CONTAINER_POOL]) >= pool_capacity(gContainerData[containerid][E_CONTAINER_POOL]));
}

stock bool:IsContainerEmpty(Container:containerid) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    return (pool_size(gContainerData[containerid][E_CONTAINER_POOL]) == 0);
}

stock bool:IsContainerSlotUsed(Container:containerid, index) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    return pool_has(gContainerData[containerid][E_CONTAINER_POOL], index);
}

stock bool:GetContainerSlotItem(Container:containerid, index, &Item:itemid) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    if (!pool_has(gContainerData[containerid][E_CONTAINER_POOL], index)) {
        return false;
    }

    return pool_get_safe(gContainerData[containerid][E_CONTAINER_POOL], index, _:itemid);
}

stock bool:GetItemContainerData(Item:itemid, &Container:containerid = INVALID_CONTAINER_ID, &index = -1) {
    if (!IsValidItem(itemid)) {
        return false;
    }

    containerid = gItemContainerID[itemid];
    index = gItemContainerSlotID[itemid];

    return true;
}
