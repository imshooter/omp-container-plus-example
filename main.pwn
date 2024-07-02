#define MAX_PLAYERS (2)

#include <open.mp>

#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_hooks>

#include ".\core\item.pwn"
#include ".\core\container.pwn"
#include ".\core\inventory.pwn"

main(){}

public OnGameModeInit() {
    new const
        ItemBuild:b = BuildItem("M4", 356),
        Container:c = CreateContainer("Container", 16)
    ;

    new
        Item:itm, ret, idx
    ;

    for (new i; i != 8; ++i) {
        itm = CreateItem(b);
        ret = AddItemToContainer(c, itm, idx);

        printf("(AddItemToContainer) -> Returns (%i) Add Item (%i) in slot (%i) to container (%i).", ret, _:itm, idx, _:c);
    }

    print("-");
    print("-");

    new
        Item:arr[MAX_CONTAINER_SLOTS],
        count
    ;

    GetContainerItems(c, arr, count);

    for (new i; i != count; ++i) {
        itm = arr[i];

        GetItemContainerData(itm, .index = idx);

        printf("(GetContainerItems) -> Item (%i) ~ Index (%i).", _:itm, idx);
    }

    print("-");
    print("-");

    for (new i = 4; --i >= 0;) {
        RemoveItemFromContainer(c, i, itm);

        printf("(RemoveItemFromContainer) -> Item (%i) removed from container (%i).", _:itm, _:c);
    }

    GetContainerItems(c, arr, count);

    for (new i; i != count; ++i) {
        itm = arr[i];

        GetItemContainerData(itm, .index = idx);

        printf("(GetContainerItems) -> Item (%i) ~ Index (%i).", _:itm, idx);
    }

    print("-");
    print("-");

    for (new i; i != 2; ++i) {
        itm = CreateItem(b);
        ret = AddItemToContainer(c, itm, idx);

        printf("(AddItemToContainer) -> Returns (%i) Add Item (%i) in slot (%i) to container (%i).", ret, _:itm, idx, _:c);
    }

    GetContainerItems(c, arr, count);

    for (new i; i != count; ++i) {
        itm = arr[i];

        GetItemContainerData(itm, .index = idx);

        printf("(GetContainerItems) -> Item (%i) ~ Index (%i).", _:itm, idx);
    }

    print("-");
    print("-");

    for (new i; i != 2; ++i) {
        GetContainerSlotItem(c, i, itm);
        
        if (!DestroyItem(itm)) {
            printf("(DestroyItem) -> Returns `false` to remove item (%i) index (%i).", _:itm, i);

            continue;
        }

        printf("(DestroyItem) -> Item (%i) index (%i) from container (%i) destroyed.", _:itm, i, _:c);
    }

    GetContainerItems(c, arr, count);

    for (new i; i != count; ++i) {
        itm = arr[i];

        GetItemContainerData(itm, .index = idx);

        printf("(GetContainerItems) -> Item (%i) ~ Index (%i).", _:itm, idx);
    }

    DestroyContainer(c);
    
    return 1;
}