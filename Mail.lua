local Mirror = include("LuaDS.Mirror")
local OrderedTable = include("LuaDS.OrderedTable")

local EasyChatSentence = Mirror:extend(OrderedTable:new(
    "type",  {0x00, 2},
    "id",    {0x02, 2},
    "words", {0x04, Array, 2, 2}
))

local MailIconData = Mirror:extend(OrderedTable:new(
    "asStruct",    {0x00, 2},
    "spriteIndex", {0x00, 0, 0, 12},
    "palIndex",    {0x00, 0, 12, 4},

    "asValue",     {0x02, 2}
))

local Mail = Mirror:extend(OrderedTable:new(
    "trainerId",              {0x00, 4},
    "trainerGender",          {0x04, 1},
    "language",               {0x05, 1},
    "gameVersion",            {0x06, 1},
    "mailType",               {0x07, 1},
    "trainerName",            {0x08, Array, 8, 2}, 
    "iconData",               {0x18, MailIconData},
    "platExclusiveFormIcons", {MailIconData.SIZE + 0x18, 2},
    "sentences",              {MailIconData.SIZE + 0x1a, Array, 3, EasyChatSentence}
))