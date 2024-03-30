/**
 * # Header
 */

#if !defined MAX_CONTAINER
    #define MAX_CONTAINER (2048)
#endif

#if !defined MAX_CONTAINER_SLOTS
    #define MAX_CONTAINER_SLOTS (128)
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
    List:gContainerList[MAX_CONTAINER]
;

/**
 * # External
 */

stock bool:IsValidContainer(containerid) {
    if (!(0 <= containerid < MAX_CONTAINER)) {
        return false;
    }
    
    return list_valid(gContainerList[containerid]);
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
    gContainerList[containerid] = list_new();

    return containerid;
}

stock bool:DestroyContainer(containerid) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    list_delete(gContainerList[containerid]);

    gContainerName[containerid][0] = EOS;
    gContainerSize[containerid] = 0;
    gContainerList[containerid] = INVALID_LIST;

    return true;
}

stock AddItemToContainer(containerid, itemid, amount) {
    if (!IsValidContainer(containerid)) {
        return -1;
    }

    if (list_size(gContainerList[containerid]) >= gContainerSize[containerid]) {
        return -1;
    }

    new
        data[E_CONTAINER_DATA]
    ;

    data[E_CONTAINER_ITEM_ID] = itemid;
    data[E_CONTAINER_ITEM_AMOUNT] = amount;

    return list_add_arr(gContainerList[containerid], data);
}

stock bool:RemoveItemFromContainer(containerid, slot) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    list_remove(gContainerList[containerid], slot);

    return true;
}

stock bool:GetContainerSlotData(containerid, slot, &itemid, &amount = 0) {
    if (!IsValidContainer(containerid)) {
        return false;
    }

    new
        data[E_CONTAINER_DATA]
    ;

    list_get_arr(gContainerList[containerid], slot, data);

    itemid = data[E_CONTAINER_ITEM_ID];
    amount = data[E_CONTAINER_ITEM_AMOUNT];

    return true;
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

stock GetContainerSize(containerid) {
    if (!IsValidContainer(containerid)) {
        return 0;
    }

    return list_size(gContainerList[containerid]);
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
