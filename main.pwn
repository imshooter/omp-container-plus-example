#define MAX_PLAYERS (2)

#include <open.mp>
#include <mysql>
#include <PawnPlus>
#include <pp-mysql>

#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_hooks>
#include <YSI_Extra\y_inline_mysql>

#include ".\core\item.pwn"
#include ".\core\item-plus.pwn"
#include ".\core\container.pwn"
#include ".\core\inventory.pwn"

/**
 * # Header
 */

static
    DBID:gAccountDBID[MAX_PLAYERS] = { DBID:1, ... },
    DBID:gItemBuildDBID[MAX_ITEM_BUILDS]
;

enum {
    ITEM_AK_47,
    ITEM_M4,
    ITEM_PIZZA,
    ITEM_HAMBURGER,
    ITEM_MEDKIT
};

static stock const
    gItemBuildKeys[][MAX_ITEM_KEY_LENGTH + 1 char] =
{
    !"ak47",
    !"m4",
    !"pizza",
    !"hamburger",
    !"medkit"
};

main(){}

/**
 * # Example
 */

stock bool:GetItemBuildByIndex(index, &ItemBuild:build) {
    if (!(0 <= index < sizeof (gItemBuildKeys))) {
        return false;
    }

    return GetKeyItemBuild(gItemBuildKeys[index], build);
}

stock bool:IsItemBuildMatchKeyByIndex(ItemBuild:build, index) {
    if (!(0 <= index < sizeof (gItemBuildKeys))) {
        return false;
    }

    return IsItemBuildMatchKey(build, gItemBuildKeys[index]);
}

stock DBID:GetAccountDatabaseID(playerid) {
    return gAccountDBID[playerid];
}

/**
 * # Calls
 */

public OnGameModeInit() {
    // Connect
    mysql_connect("localhost", "root", "", "i");

    // Retrieve
    LoadItemBuilds();

    return 1;
}

public OnPlayerConnect(playerid) {
    LoadInventory(playerid);
    
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    SaveInventory(playerid);
    
    return 1;
}

/**
 * # Database
 */

void:LoadItemBuilds() {
    inline const OnRetrieve() {
        new const
            rows = cache_num_rows()
        ;

        if (!rows) {
            @return 1;
        }

        enum _:E_ITEM_BUILD_DATA {
            DBID:E_ITEM_BUILD_DBID,
            E_ITEM_BUILD_NAME[MAX_ITEM_BUILD_NAME + 1],
            E_ITEM_BUILD_KEY[MAX_ITEM_BUILD_NAME + 1],
            E_ITEM_BUILD_MODEL
        };

        new
            data[E_ITEM_BUILD_DATA]
        ;

        for (new i; i < rows; ++i) {
            cache_get_value_int(i, "id", _:data[E_ITEM_BUILD_DBID]);
            cache_get_value(i, "name", data[E_ITEM_BUILD_NAME]);
            cache_get_value(i, "name-key", data[E_ITEM_BUILD_KEY]);
            cache_get_value_int(i, "model", data[E_ITEM_BUILD_MODEL]);

            new const
                ItemBuild:b = BuildItem(data[E_ITEM_BUILD_NAME], data[E_ITEM_BUILD_MODEL])
            ;

            gItemBuildDBID[b] = data[E_ITEM_BUILD_DBID];

            SetKeyItemBuild(data[E_ITEM_BUILD_KEY], b);
        }
    }

    MySQL_TQueryInline(MYSQL_DEFAULT_HANDLE, using inline OnRetrieve, "SELECT * FROM `item-builds`;");
}

void:LoadInventory(playerid) {
    inline const OnRetrieve() {
        new const
            rows = cache_num_rows()
        ;

        if (!rows) {
            @return 1;
        }

        new
            row,
            lastRow,
            ItemBuild:build,
            Item:itemid,
            extraName[MAX_ITEM_EXTRA_NAME + 1],
            uuid[UUID_LEN],
            buildNameKey[MAX_ITEM_KEY_LENGTH + 1],
            bool:hasData,
            attributeKey[MAX_ITEM_KEY_LENGTH + 1],
            attributeValue
        ;

        for (new i; i < rows; ++i) {
            cache_get_value_int(i, "row", row);

            if (lastRow != row) {
                cache_get_value(i, "extra-name", extraName);
                cache_get_value(i, "uuid", uuid);
                cache_get_value(i, "name-key", buildNameKey);

                GetKeyItemBuild(buildNameKey, build);

                itemid = CreateItem(
                    build,
                    .uuid = uuid
                );

                if (itemid == INVALID_ITEM_ID) {
                    SendClientMessage(playerid, -1, "WARN: The server has reached the limit of creating items and your inventory is incomplete.");
                    
                    break;
                }

                SetItemExtraName(itemid, extraName);

                if (AddItemToInventory(playerid, itemid)) {
                    break;
                }

                lastRow = row;
            }

            cache_is_value_null(i, "key", hasData);
            hasData = !hasData;

            if (hasData) {
                cache_get_value(i, "key", attributeKey);
                cache_get_value_int(i, "value", attributeValue);

                SetItemExtraData(
                    itemid,
                    attributeKey,
                    attributeValue
                );
            }
        }
    }

    MySQL_TQueryInline(MYSQL_DEFAULT_HANDLE, using inline OnRetrieve, "\
        SELECT \
            DENSE_RANK() OVER (ORDER BY `it`.`uuid`) AS `row`, \
            `it`.`owner-id`, \
            `it`.`extra-name`, \
            `it`.`uuid`, \
            `ib`.`name-key`, \
            `ia`.`key`, \
            `ia`.`value` \
        FROM \
            `items` AS `it` \
        JOIN \
            `item-builds` AS `ib` ON `it`.`item-build-id` = `ib`.`id` \
        LEFT JOIN \
            `item-attributes` AS `ia` ON `it`.`uuid` = `ia`.`item-uuid` \
        WHERE \
            `it`.`owner-id` = %i;", _:GetAccountDatabaseID(playerid)
    );
}

void:SaveInventory(playerid) {
    if (IsInventoryEmpty(playerid)) {
        return;
    }

    new
        ItemBuild:build,
        Item:itemid,
        uuid[UUID_LEN],
        extraName[MAX_ITEM_EXTRA_NAME + 1],
        Map:map,
        data[2],
        List:list = list_new()
    ;

    new const
        String:str = @("INSERT INTO `items` (`owner-id`, `item-build-id`, `extra-name`, `uuid`) VALUES ")
    ;

    foreach ((_:itemid) : InventoryItem(playerid)) {
        GetItemBuild(itemid, build);
        GetItemUUID(itemid, uuid);
        GetItemExtraName(itemid, extraName);

        str_append_format(str, "(%i, %i, '%e', '%e'), ", _:GetAccountDatabaseID(playerid), _:gItemBuildDBID[build], extraName, uuid);

        if (!GetItemExtraDataMap(itemid, map)) {
            continue;
        }

        data[0] = _:str_acquire(@(uuid));
        data[1] = _:map_clone(map);

        list_add_arr(list, data);
    }

    mysql_tquery_s(MYSQL_DEFAULT_HANDLE,
        str_addr(
            str_replace(str, ".{2}$", " ON DUPLICATE KEY UPDATE `uuid` = `uuid`;")
        ),
        "OnItemExtraDataSaveAsync", "ii", playerid, _:list
    );
}

forward void:OnItemExtraDataSaveAsync(playerid, List:list);
public void:OnItemExtraDataSaveAsync(playerid, List:list) {
    if (list_size(list) != 0) {
        new
            data[2],
            attributeKey[MAX_ITEM_KEY_LENGTH + 1],
            attributeValue
        ;

        new const
            String:str = @("INSERT INTO `item-attributes` (`key`, `value`, `item-uuid`) VALUES ")
        ;

        for (new Iter:a = list_iter(list); iter_inside(a); iter_move_next(a)) {
            iter_get_arr(a, data);

            for (new Iter:b = map_iter(Map:data[1]); iter_inside(b); iter_move_next(b)) {
                if (!iter_get_key_str_safe(b, attributeKey)) {
                    continue;
                }

                if (!iter_get_value_safe(b, attributeValue)) {
                    continue;
                }

                str_append_format(str, "('%e', %i, '%E'), ", attributeKey, attributeValue, String:data[0]);
            }

            str_delete(String:data[0]);
            map_delete(Map:data[1]);
        }

        mysql_tquery_s(MYSQL_DEFAULT_HANDLE,
            str_addr(
                str_replace(str, ".{2}$", " ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);")
            )
        );
    }

    list_delete(list);
}