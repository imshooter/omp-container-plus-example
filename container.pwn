#include <open.mp>
#include <PawnPlus>

#if !defined MAX_CONTAINER
    #define MAX_CONTAINER (2048)
#endif

#if !defined MAX_CONTAINER_SLOTS
    #define MAX_CONTAINER_SLOTS (64)
#endif

#if !defined MAX_CONTAINER_NAME
    #define MAX_CONTAINER_NAME (16)
#endif

static enum _:E_CONTAINER_DATA {
    E_CONTAINER_ITEM_ID,
    E_CONTAINER_ITEM_AMOUNT
};

static
    gContainerName[MAX_CONTAINER][MAX_CONTAINER_NAME char],
    gContainerSize[MAX_CONTAINER],
    List:gContainerListID[MAX_CONTAINER]
;

main(){}

stock bool:IsValidContainer(containerid) {
    if (!(0 <= containerid < MAX_CONTAINER)) {
        return false;
    }
    
    return list_valid(gContainerListID[containerid]);
}

stock CreateContainer(const name[], size) {
    if (!(0 <= size < MAX_CONTAINER_SLOTS)) {
        return -1;
    }

    new
        containerid = -1
    ;

    for (new i; i < MAX_CONTAINER; i++) {
        if (!IsValidContainer(i)) {
            containerid = i;
            break;
        }
    }

    if (containerid == -1) {
        return -1;
    }

    strpack(gContainerName[containerid], name);
    gContainerSize[containerid] = size;
    gContainerListID[containerid] = list_new();

    return containerid;
}

stock bool:AddItemToContainer(containerid, itemid, amount) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    if (list_size(gContainerListID[containerid]) >= gContainerSize[containerid]) {
        return false;
    }

    new
        data[E_CONTAINER_DATA]
    ;

    data[E_CONTAINER_ITEM_ID] = itemid;
    data[E_CONTAINER_ITEM_AMOUNT] = amount;

    list_add_arr(gContainerListID[containerid], data);

    return true;
}

stock bool:GetContainerSlotData(containerid, slot, &itemid, &amount) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    new
        data[E_CONTAINER_DATA]
    ;

    list_get_arr(gContainerListID[containerid], slot, data);

    itemid = data[E_CONTAINER_ITEM_ID];
    amount = data[E_CONTAINER_ITEM_AMOUNT];

    return true;
}

stock GetContainerSize(containerid) {
    if (!IsValidContainer(containerid)) {
        return 0;
    }

    return list_size(gContainerListID[containerid]);
}

stock bool:SetContainerMaxSize(containerid, size) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    if (!(0 <= size < MAX_CONTAINER_SLOTS)) {
        return false;
    }

    gContainerSize[containerid] = size;

    return true;
}

stock GetContainerMaxSize(containerid) {
    if (!IsValidContainer(containerid)) {
        return 0;
    }

    return gContainerSize[containerid];
}

stock bool:SetContainerName(containerid, const name[], size = sizeof (name)) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    strpack(gContainerName[containerid], name, size);

    return true;
}

stock bool:GetContainerName(containerid, name[], size = sizeof (name)) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    strunpack(name, gContainerName[containerid], size);

    return true;
}

/**
 * # Tests
 */

public OnGameModeInit() {
    new const
        containerid1 = CreateContainer("Container 1", 8),
        containerid2 = CreateContainer("Container 2", 8)
    ;

    // Add

    AddItemToContainer(containerid1, 90, 100);
    AddItemToContainer(containerid1, 91, 110);
    AddItemToContainer(containerid1, 92, 120);
    AddItemToContainer(containerid1, 93, 130);
    AddItemToContainer(containerid1, 94, 140);

    AddItemToContainer(containerid2, 95, 150);
    AddItemToContainer(containerid2, 96, 160);
    AddItemToContainer(containerid2, 97, 170);
    AddItemToContainer(containerid2, 98, 180);
    AddItemToContainer(containerid2, 99, 190);

    // Check

    new
        name[MAX_CONTAINER_NAME],
        itemid,
        amount
    ;

    GetContainerName(containerid1, name);
    printf("1. name: %s ~ Max size: %i", name, GetContainerMaxSize(containerid1));

    SetContainerName(containerid1, "Cnt 1");
    SetContainerMaxSize(containerid1, 16);
    GetContainerName(containerid1, name);
    printf("2. name: %s ~ Max size: %i", name, GetContainerMaxSize(containerid1));
    
    for (new i, size = GetContainerSize(containerid1); i < size; i++) {
        GetContainerSlotData(containerid1, i, itemid, amount);

        printf("Slot: %i ~ Item: %i ~ Amount: %i", i, itemid, amount);
    }

    print("-");

    for (new i, size = GetContainerSize(containerid2); i < size; i++) {
        GetContainerSlotData(containerid2, i, itemid, amount);

        printf("Slot: %i ~ Item: %i ~ Amount: %i", i, itemid, amount);
    }
    
    return 1;
}

/**
 *  [Info] 1. name: Container 1 ~ Max size: 8
 *  [Info] 2. name: Cnt 1 ~ Max size: 16
 *  [Info] Slot: 0 ~ Item: 90 ~ Amount: 100
 *  [Info] Slot: 1 ~ Item: 91 ~ Amount: 110
 *  [Info] Slot: 2 ~ Item: 92 ~ Amount: 120
 *  [Info] Slot: 3 ~ Item: 93 ~ Amount: 130
 *  [Info] Slot: 4 ~ Item: 94 ~ Amount: 140
 *  [Info] -
 *  [Info] Slot: 0 ~ Item: 95 ~ Amount: 150
 *  [Info] Slot: 1 ~ Item: 96 ~ Amount: 160
 *  [Info] Slot: 2 ~ Item: 97 ~ Amount: 170
 *  [Info] Slot: 3 ~ Item: 98 ~ Amount: 180
 *  [Info] Slot: 4 ~ Item: 99 ~ Amount: 190
 */
