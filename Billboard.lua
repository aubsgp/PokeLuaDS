-- Billboards are, somewhat simplifying, the 3d objects which are generated from 2d objects, angled towards the camera. 
-- The game generates one for each map object (which represent trainers, cut trees, etc), and the billboards are what actually gets fed into the graphics pipeline. 
-- They are tracked via linked list format. The size of a single billboard is 0xC4 (=196) bytes.
-- https://github.com/pret/pokeplatinum/blob/main/include/billboard.h

local Pos = require("LuaDS.Pos")
local OrderedTable = require("LuaDS.OrderedTable")
local Mirror = require("LuaDS.Mirror")

local Billboard = Mirror:extend(OrderedTable:new(
    "pos",           {0x00, Pos}, -- size = 0x0C
    "scale",         {0x0C, Pos}, -- size = 0x0C
    "MtxFx33",       {0x18, 4},
    "callbackParam", {0x1C, 4},
    "callback",      {0x20, 4},
    "draw",          {0x24, 1},
    "list",          {0x28, 4},
    "anims",         {0x2C, 4},
    -- skipping renderObj
    "modelSet",      {0x84, 4},
    "model",         {0x88, 4},
    "texture",       {0x8C, 4},
    "animTexture",   {0x90, 4},
    "texKey",        {0x94, 4},
    "tex4x4Key",     {0x98, 4},
    "plttKey",       {0x9C, 4},
    -- skipping gfxSequence and vramTransfer
    "state",         {0xB4, 1},
    "animNum",       {0xB6, 2},
    "frameNum",      {0xB8, 4},
    "next",          {0xBC, 4},
    "prev",          {0xC0, 4}
))

local BillboardList = Mirror:extend(OrderedTable:new(
    "active",                    {0x00, 1},
    "draw",                      {0x01, 1},
    "unused",                    {0x02, 1},
    "redraw",                    {0x03, 1},
    "billboards",                {0x04, 4},
    "capacity",                  {0x08, 4},
    "sentinelData",              {0x0C, Billboard},
    "freeBillboards",            {Billboard.SIZE + 0x0C, 4},
    "freeBillboardHead",         {Billboard.SIZE + 0x10, 4},
    "allocator",                 {Billboard.SIZE + 0x14, 4},
    "BillboardListVRAMTransfer", {Billboard.SIZE + 0x18, 4}
))
BillboardList.cache = {}



local function get_next_or_prev(billboard, which) -- Intentionally not attached to Billboard so it can be "private"
    local memnode = billboard.node and billboard.node:offset(billboard:offset_of(which)):follow()
    local addr = (memnode and memnode:get_address()) or billboard[which]
    if not addr then
        return false
    end

    if BillboardList.cache[addr] then
        return BillboardList.cache[addr]
    end

    local next_bb = (memnode and Billboard:from_node(memnode)) or Billboard:from_addr(addr)
    if not next_bb then
        return false
    end
    
    BillboardList.cache[addr] = next_bb
    return next_bb
end

function Billboard:get_prev()
    return get_next_or_prev(self, "prev")
end

function Billboard:get_next()
    return get_next_or_prev(self, "next")
end

return {
    BillboardList = BillboardList,
    Billboard = Billboard
}