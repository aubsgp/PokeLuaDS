-- Billboards are, somewhat simplifying, the 3d objects which are generated from 2d objects, angled towards the camera. 
-- The game generates one for each map object (which represent trainers, cut trees, etc), and the billboards are what actually gets fed into the graphics pipeline. 
-- They are tracked via linked list format. The size of a single billboard is 0xC4 (=196) bytes.
-- See https://github.com/pret/pokeplatinum/blob/main/include/billboard.h#L22.

local Pos = require("LuaDS.Pos")
local Mirror = require("LuaDS.Mirror")

local Billboard = Mirror:extend({
    pos           = {0x00, Pos}, -- size = 0x0C
    scale         = {0x0C, Pos}, -- size = 0x0C
    MtxFx33       = {0x18, 4},
    callbackParam = {0x1C, 4},
    callback      = {0x20, 4},
    draw          = {0x24, 1},
    list          = {0x28, 4},
    anims         = {0x2C, 4},
    -- skipping renderObj
    modelSet      = {0x84, 4},
    model         = {0x88, 4},
    texture       = {0x8C, 4},
    animTexture   = {0x90, 4},
    texKey        = {0x94, 4},
    tex4x4Key     = {0x98, 4},
    plttKey       = {0x9C, 4},
    -- skipping gfxSequence and vramTransfer
    state         = {0xB4, 1},
    animNum       = {0xB6, 2},
    frameNum      = {0xB8, 4},
    next          = {0xBC, 4},
    prev          = {0xC0, 4},
})