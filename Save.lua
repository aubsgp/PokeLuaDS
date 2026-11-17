local Mirror = require("LuaDS.Mirror")
local OrderedTable = require("LuaDS.OrderedTable")

local SaveData = Mirror:extend(OrderedTable:new(
    "backupExists",     {0x00, 1},
    "dataExists",       {0x01, 1},
    "isNewGameData",    {0x02, 1},
    "fullSaveRequired", {0x03, 1},
    "loadCheckStatus",  {0x04, 4},
    "body",             {0x08, SaveDataBody},
    "globalCounter",    {SaveDataBody.SIZE + 0x08, 4},
    "blockCounters",    {SaveDataBody.SIZE + 0x0C, Array, 2, 4},
    "blockOffsets",     {
    "pageInfo",         {
    "blockInfo",        {
    "state",            {
    "sectorSwitch",     {
    "sectorCounter",    {
))