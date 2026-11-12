local MemNode = require("LuaDS.MemNode")

local true_mem_base = MemNode:root(0x02000ba8)
local base = true_mem_base:follow():offset(0x20):follow()

local battlesystem = base:offset(0x417fc)
local battlecontext = battlesystem:offset(0x30):follow(0)
local name = base:offset(0x7c)
local map = base:offset(0x1294)

local party = base:offset(0xb4)
local box = base:offset(0xcf44)
local battlemon = battlecontext:offset(0x2d40)
local battle_parties = battlesystem:offset(0x68)

local actormanager = base:offset(0x23730)
local player = actormanager:offset(0x124):follow()
player:add_parent(actormanager, {0x14c}) -- Added as an additional check that must pass for us to trust any memory addresses.

local fieldsystem = actormanager:offset(0x128):follow()
local camera = fieldsystem:offset(0x24):follow()
local obstructions = base:offset(0x217a8)

return {
    base = base,
    
    battlesystem = battlesystem,
    battlecontext = battlecontext,
    name = name,
    map = map,

    party = party,
    box = box,
    battlemon = battlemon,
    battle_parties = battle_parties,

    actormanager = actormanager,
    player = player,

    fieldsystem = fieldsystem,
    camera = camera,
    obstructions = obstructions,
}