#include <open.mp>
#include <PawnPlus>

#include ".\container\container.pwn"
#include ".\container\inventory.pwn"

main(){}

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
