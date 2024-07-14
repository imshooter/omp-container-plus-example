#if defined _INC_ITEM_
    #endinput
#endif

#define _INC_ITEM_

#include <uuid>

#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

#if !defined MAX_ITEM_BUILDS
    #define MAX_ITEM_BUILDS (ItemBuild:128)
#endif

#if !defined MAX_ITEMS
    #define MAX_ITEMS (Item:8192)
#endif

#if !defined MAX_ITEM_BUILD_NAME
    #define MAX_ITEM_BUILD_NAME (32)
#endif

#define INVALID_ITEM_BUILD_ID (ItemBuild:-1)
#define INVALID_ITEM_ID (Item:-1)

static enum E_ITEM_BUILD_DATA {
    E_ITEM_BUILD_NAME[MAX_ITEM_BUILD_NAME + 1],
    E_ITEM_BUILD_MODEL_ID
};

static enum E_ITEM_DATA {
    ItemBuild:E_ITEM_BUILD_ID,

    // TODO:

    Float:E_ITEM_X,
    Float:E_ITEM_Y,
    Float:E_ITEM_Z,

    Float:E_ITEM_ROT_X,
    Float:E_ITEM_ROT_Y,
    Float:E_ITEM_ROT_Z,

    E_ITEM_WORLD_ID,
    E_ITEM_INTERIOR_ID,

    Button:E_ITEM_BUTTON_ID,
    STREAMER_TAG_OBJECT:E_ITEM_OBJECT_ID,

    // UUID:

    E_ITEM_UUID[UUID_LEN]
};

static
    gItemBuildData[MAX_ITEM_BUILDS][E_ITEM_BUILD_DATA],
    gItemData[MAX_ITEMS][E_ITEM_DATA]
;

const static
    ITEM_BUILD_ITER_SIZE = _:MAX_ITEM_BUILDS,
    ITEM_ITER_SIZE = _:MAX_ITEMS
;

new
    Iterator:ItemBuild<ItemBuild:ITEM_BUILD_ITER_SIZE>,
    Iterator:Item<Item:ITEM_ITER_SIZE>
;

/**
 * # Functions
 */

forward ItemBuild:BuildItem(const name[], modelid);
forward bool:IsValidItemBuild(ItemBuild:build);
forward bool:GetItemBuildName(ItemBuild:build, dest[], size = sizeof (dest));
forward GetItemBuildModel(ItemBuild:build);

forward Item:CreateItem(ItemBuild:build, const uuid[] = "");
forward bool:IsValidItem(Item:itemid);
forward bool:GetItemBuild(Item:itemid, &ItemBuild:build);
forward bool:GetItemUUID(Item:itemid, dest[], size = sizeof (dest));

/**
 * # External
 */

forward OnItemBuild(ItemBuild:build);
forward OnItemCreate(Item:itemid);
forward OnItemDestroy(Item:itemid);

/**
 * # Item Build
 */

stock ItemBuild:BuildItem(const name[], modelid) {
    new const
        ItemBuild:id = ItemBuild:Iter_Alloc(ItemBuild)
    ;

    if (_:id == INVALID_ITERATOR_SLOT) {
        return INVALID_ITEM_BUILD_ID;
    }

    strcopy(gItemBuildData[id][E_ITEM_BUILD_NAME], name);
    gItemBuildData[id][E_ITEM_BUILD_MODEL_ID] = modelid;

    return id;
}

stock bool:IsValidItemBuild(ItemBuild:build) {
    return (0 <= _:build < ITEM_BUILD_ITER_SIZE) && Iter_Contains(ItemBuild, build);
}

stock bool:GetItemBuildName(ItemBuild:build, dest[], size = sizeof (dest)) {
    if (!IsValidItemBuild(build)) {
        return false;
    }

    strcopy(dest, gItemBuildData[build][E_ITEM_BUILD_NAME], size);

    return true;
}

stock GetItemBuildModel(ItemBuild:build) {
    if (!IsValidItemBuild(build)) {
        return 0;
    }

    return gItemBuildData[build][E_ITEM_BUILD_MODEL];
}

/**
 * # Item
 */

stock Item:CreateItem(ItemBuild:build, const uuid[] = "") {
    new const
        Item:id = Item:Iter_Alloc(Item)
    ;

    if (_:id == INVALID_ITERATOR_SLOT) {
        return INVALID_ITEM_ID;
    }

    if (isnull(uuid)) {
        UUID(gItemData[id][E_ITEM_UUID]);
    } else {
        strcopy(gItemData[id][E_ITEM_UUID], uuid);
    }

    gItemData[id][E_ITEM_BUILD_ID] = build;

    CallLocalFunction("OnItemCreate", "i", _:id);

    return id;
}

stock bool:IsValidItem(Item:itemid) {
    return (0 <= _:itemid < ITEM_ITER_SIZE) && Iter_Contains(Item, itemid);
}

stock bool:DestroyItem(Item:itemid) {
    if (!IsValidItem(itemid)) {
        return false;
    }

    Iter_Remove(Item, itemid);

    CallLocalFunction("OnItemDestroy", "i", _:itemid);

    return true;
}

stock bool:GetItemBuild(Item:itemid, &ItemBuild:build) {
    if (!IsValidItem(itemid)) {
        return false;
    }

    build = gItemData[itemid][E_ITEM_BUILD_ID];

    return true;
}

stock bool:GetItemUUID(Item:itemid, dest[], size = sizeof (dest)) {
    if (!IsValidItem(itemid)) {
        return false;
    }

    strcopy(dest, gItemData[itemid][E_ITEM_UUID], size);

    return true;
}