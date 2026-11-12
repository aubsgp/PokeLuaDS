-- Coordinates as Fx32 (fixed point 32-bit) values. 1 bit for the sign, then 19 bits for the integer portion, then 12 decimal bits. Graphics coordinates use these in the game's engine.
-- Note that each tile is 16 (=2^4) pixels.
local here = (...):match("(.-)[^%.]+$")
local Data = require("LuaDS.Data")
local Mirror = require("LuaDS.Mirror")

local Pos = Mirror:extend({
    x = {0x00, 4},
    y = {0x04, 4},
    z = {0x08, 4},
})
Pos.Fx32_ONE = 0x00001000

function Pos:blank()
    local t = {}
    for i = 0x01, 0x0C do
        t[i] = 0
    end
    return Pos:new(Data:new(t))
end

function Pos:to_coords()
    return {self.x, self.y, self.z}
end

function Pos:from_coords(coords)
    local ret = self:blank()
    
    ret.x = coords[1]
    ret.y = coords[2]
    ret.z = coords[3]

    return ret
end

function Pos:to_pixels()
    local x = self.x / Pos.Fx32_ONE
    local y = self.y / Pos.Fx32_ONE
    local z = self.z / Pos.Fx32_ONE
    return {x, y, z}
end

function Pos:from_pixels(pixels)
    local ret = self:blank()

    ret.x = pixels[1] * Pos.Fx32_ONE
    ret.y = pixels[2] * Pos.Fx32_ONE
    ret.z = pixels[3] * Pos.Fx32_ONE

    return ret
end

function Pos:to_tiles()
    local pixels = self:to_pixels()

    local x = pixels[1] / 16
    local y = pixels[2] / 16
    local z = pixels[3] / 16

    return {x, y, z}
end

function Pos:from_tiles(tiles)
    local x = tiles[1] * 16
    local y = tiles[2] * 16
    local z = tiles[3] * 16

    return self:from_pixels({x, y, z})
end

function Pos:from_dir(dir)
    if dir == 0 then -- North
        return self:from_tiles({0, 0, -1})
    elseif dir == 1 then -- South
        return self:from_tiles({0, 0, 1})
    elseif dir == 2 then -- West
        return self:from_tiles({-1, 0, 0})
    elseif dir == 3 then -- East
        return self:from_tiles({1, 0, 0})
    else
        return self:from_tiles({0, 0, 0})
    end
end

function Pos.__add(pos1, pos2)
    return Pos:from_coords({pos1.x + pos2.x, pos1.y + pos2.y, pos1.z + pos2.z})
end

function Pos.__sub(pos1, pos2)
    return Pos:from_coords({pos1.x - pos2.x, pos1.y - pos2.y, pos1.z - pos2.z})
end

function Pos.__mul(pos, scalar) -- scalar is assumed to be in fx32
    return Pos:from_coords({
        math.floor(pos.x * (scalar/Pos.Fx32_ONE)),
        math.floor(pos.y * (scalar/Pos.Fx32_ONE)),
        math.floor(pos.z * (scalar/Pos.Fx32_ONE)),
    })
end

function Pos.__div(pos, scalar) -- scalar is assumed to be in fx32
    return Pos:from_coords({
        math.floor(pos.x / (scalar/Pos.Fx32_ONE)),
        math.floor(pos.y / (scalar/Pos.Fx32_ONE)),
        math.floor(pos.z / (scalar/Pos.Fx32_ONE)),
    })
end

return Pos