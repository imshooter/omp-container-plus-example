#include <open.mp>
#include <PawnPlus>

#if !defined MAX_CONTAINER
    #define MAX_CONTAINER (2048)
#endif

#if !defined MAX_CONTAINER_SLOTS
    #define MAX_CONTAINER_SLOTS (64)
#endif

static enum _:E_CONTAINER_DATA {
    E_CONTAINER_ITEM_ID,
    E_CONTAINER_ITEM_AMOUNT
};

static
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

stock CreateContainer(size) {
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

/**
 * # Tests
 */

public OnGameModeInit() {
    new const
        containerid1 = CreateContainer(8),
        containerid2 = CreateContainer(8)
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
        itemid,
        amount
    ;

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
