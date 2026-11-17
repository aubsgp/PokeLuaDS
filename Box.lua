typedef struct PCBoxes {
    u32 currentBoxID;
    BoxPokemon boxMons[MAX_PC_BOXES][MAX_MONS_PER_BOX];
    u16 names[MAX_PC_BOXES][PC_BOX_NAME_BUFFER_LEN];
    u8 wallpapers[MAX_PC_BOXES];
    u8 unlockedWallpapers;
} PCBoxes;
-- https://github.com/pret/pokeplatinum/blob/main/include/pc_boxes.h

local Mirror = require("LuaDS.Mirror")
local OrderedTable = require("LuaDS.OrderedTable")

local PCBoxes = Mirror:extend(OrderedTable:new(
    "currentBoxID",       {0x00,                                                          4},
    "boxMons",            {0x04,                                                         {Array, 18, {Array, 30, BoxPokemon}}},
    "names",              {(18 * 30 * BoxPokemon.SIZE) + 0x04,                           {Array, 18, {Array, 20, 2}}},
    "wallpapers",         {(18 * 30 * BoxPokemon.SIZE) + (18 * 20 * 2) + 0x04,           {Array, 18, 2}},
    "unlockedWallpapers", {(18 * 30 * BoxPokemon.SIZE) + (18 * 20 * 2) + (18 * 2) + 0x04, 0x04}
))