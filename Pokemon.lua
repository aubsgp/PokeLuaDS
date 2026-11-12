local Error = require("LuaDS.Error")
local Bitwise = require("LuaDS.Bitwise")
local Array = require("LuaDS.Array")
local Mirror = require("LuaDS.Mirror")

local Data = require("PokeLuaDS.PokeData")

local Metadata = Mirror:extend({
    personality     = {0x00, 4},

    encryptionFlags = {0x04, 2},
    partyDecrypted  = {0x04, 0, 0, 1},
    boxDecrypted    = {0x04, 0, 1, 1},
    checksumFailed  = {0x04, 0, 2, 1},

    checksum        = {0x06, 2},
})

local BoxPokemon = Mirror:extend({
    metadata = {0x00, Metadata},


    -- Block A
    species        = {Metadata.SIZE + 0x00, 2},
    heldItem       = {Metadata.SIZE + 0x02, 2},
    otID           = {Metadata.SIZE + 0x04, 4},
    exp            = {Metadata.SIZE + 0x08, 4},
    friendship     = {Metadata.SIZE + 0x0C, 1},
    ability        = {Metadata.SIZE + 0x0D, 1},
    markings       = {Metadata.SIZE + 0x0E, 1},
    originLanguage = {Metadata.SIZE + 0x0F, 1},

    evs            = {Metadata.SIZE + 0x10, Array:extend(6, 1)},
    hpEV           = {Metadata.SIZE + 0x10, 1},
    atkEV          = {Metadata.SIZE + 0x11, 1},
    defEV          = {Metadata.SIZE + 0x12, 1},
    speedEV        = {Metadata.SIZE + 0x13, 1},
    spAtkEV        = {Metadata.SIZE + 0x14, 1},
    spDefEV        = {Metadata.SIZE + 0x15, 1},

    contestStats   = {Metadata.SIZE + 0x16, Array:extend(6, 1)},
    cool           = {Metadata.SIZE + 0x16, 1},
    beauty         = {Metadata.SIZE + 0x17, 1},
    cute           = {Metadata.SIZE + 0x18, 1},
    smart          = {Metadata.SIZE + 0x19, 1},
    tough          = {Metadata.SIZE + 0x1A, 1},
    sheen          = {Metadata.SIZE + 0x1B, 1},

    ribbonsDS1     = {Metadata.SIZE + 0x1C, 4},


    -- Block B
    moves              = {Metadata.SIZE + 0x20, Array:extend(4, 2)},
    moveCurrentPPs     = {Metadata.SIZE + 0x28, Array:extend(4, 1)},
    movePPUps          = {Metadata.SIZE + 0x2C, Array:extend(4, 1)},

    ivs                = {Metadata.SIZE + 0x30, 4},
    hpIV               = {Metadata.SIZE + 0x30, 0, 0, 5},
    atkIV              = {Metadata.SIZE + 0x30, 0, 5, 5},
    defIV              = {Metadata.SIZE + 0x30, 0, 10, 5},
    speedIV            = {Metadata.SIZE + 0x30, 0, 15, 5},
    spAtkIV            = {Metadata.SIZE + 0x30, 0, 20, 5},
    spDefIV            = {Metadata.SIZE + 0x30, 0, 25, 5},
    isEgg              = {Metadata.SIZE + 0x30, 0, 30, 1},
    hasNickname        = {Metadata.SIZE + 0x30, 0, 31, 1},

    ribbonsGBA         = {Metadata.SIZE + 0x34, 4},

    genderForm         = {Metadata.SIZE + 0x38, 1},
    fatefulEncounter   = {Metadata.SIZE + 0x38, 0, 0, 1},
    gender             = {Metadata.SIZE + 0x38, 0, 1, 2},
    form               = {Metadata.SIZE + 0x38, 0, 3, 5},

    unused1            = {Metadata.SIZE + 0x39, 1}, -- First 6 bits track Shiny Leaves from HGSS.
    unused2            = {Metadata.SIZE + 0x3A, 2},
    EggLocation_PtHGSS = {Metadata.SIZE + 0x3C, 2},
    MetLocation_PtHGSS = {Metadata.SIZE + 0x3E, 2},


    -- Block C
    nickname   = {Metadata.SIZE + 0x40, Array:extend(11, 2)},
    unused3    = {Metadata.SIZE + 0x56, 1},
    originGame = {Metadata.SIZE + 0x57, 1},
    ribbonsDS2 = {Metadata.SIZE + 0x58, 8},


    -- Block D
    otName           = {Metadata.SIZE + 0x60, Array:extend(8, 2)},
    eggYear          = {Metadata.SIZE + 0x70, 1},
    eggMonth         = {Metadata.SIZE + 0x71, 1},
    eggDay           = {Metadata.SIZE + 0x72, 1},
    metYear          = {Metadata.SIZE + 0x73, 1},
    metMonth         = {Metadata.SIZE + 0x74, 1},
    metDay           = {Metadata.SIZE + 0x75, 1},
    EggLocation_DP   = {Metadata.SIZE + 0x76, 2},
    MetLocation_DP   = {Metadata.SIZE + 0x78, 2},
    pokerus          = {Metadata.SIZE + 0x7A, 1},
    pokeball         = {Metadata.SIZE + 0x7B, 1},

    metLevelOTGender = {Metadata.SIZE + 0x7C, 1},
    metLevel         = {Metadata.SIZE + 0x7C, 0, 0, 7},
    otGender         = {Metadata.SIZE + 0x7C, 0, 7, 1},

    metTerrain       = {Metadata.SIZE + 0x7D, 1},
    unused4          = {Metadata.SIZE + 0x7E, 2},
})

function BoxPokemon:compute_shuffle()
    local shift_val = Bitwise.rshift(Bitwise.band(self.metadata.personality, 0x3E000), 13) % 24
    
    local blocks = {0, 1, 2, 3}
    local shuffle = {}

    local sv1 = math.floor(shift_val / 6) + 1
    shuffle[1] = blocks[sv1]
    table.remove(blocks, sv1)

    local sv2 = math.floor((shift_val % 6) / 2) + 1
    shuffle[2] = blocks[sv2];
    table.remove(blocks, sv2)

    local sv3 = (shift_val % 2) + 1
    shuffle[3] = blocks[sv3];
    table.remove(blocks, sv3)

    shuffle[4] = blocks[1];

    return shuffle;
end

function BoxPokemon:encrypt()
    return self.data:shuffle_blocks(self:compute_shuffle(), Metadata.SIZE, 0x20):encrypt(self.metadata.checksum, Metadata.SIZE, BoxPokemon.SIZE)
end

function BoxPokemon:decrypt()
    return self.data:decrypt(self.metadata.checksum, Metadata.SIZE, BoxPokemon.SIZE):unshuffle_blocks(self:compute_shuffle(), Metadata.SIZE, 0x20)
end

function BoxPokemon:from_node(mem_node)
    local addr = mem_node:get_address()
    if not addr then
        return false
    end

    local boxmon = BoxPokemon:new(Data:new(memory.readbyterange(addr, BoxPokemon.SIZE)))
    if not boxmon then
        return false
    end

    if boxmon.metadata.boxDecrypted == 0 then
        boxmon = BoxPokemon:new(boxmon:decrypt())
        if not boxmon then
            return false
        end
    end

    boxmon.node = mem_node
    return boxmon
end

function BoxPokemon:write_to_memory(addr)
    if not addr then
        if not self.node then
            Error("Attempt to write to memory without an address.")
        end

        addr = self.node:get_address()
        if not addr then
            return false
        end
    end

    self.metadata.checksum = self.data:checksum(Metadata.SIZE, BoxPokemon.SIZE)
    self.metadata.data:write_to_memory(addr, 0, Metadata.SIZE)

    local box_data = self.data
    if self.metadata.boxDecrypted == 0 then
        box_data = self:encrypt()
    end

    box_data:write_to_memory(addr + Metadata.SIZE, Metadata.SIZE, BoxPokemon.SIZE)
    return true
end

local PartyPokemon = Mirror:extend({
    boxPokemon = {0x00, BoxPokemon},

    status        = {BoxPokemon.SIZE + 0x00, 4},
    level         = {BoxPokemon.SIZE + 0x04, 1},
    ballCapsuleID = {BoxPokemon.SIZE + 0x05, 1},
    hp            = {BoxPokemon.SIZE + 0x06, 2},

    stats         = {BoxPokemon.SIZE + 0x08, Array:extend(6, 2)},
    maxHP         = {BoxPokemon.SIZE + 0x08, 2},
    attack        = {BoxPokemon.SIZE + 0x0A, 2},
    defense       = {BoxPokemon.SIZE + 0x0C, 2},
    speed         = {BoxPokemon.SIZE + 0x0E, 2},
    spAtk         = {BoxPokemon.SIZE + 0x10, 2},
    spDef         = {BoxPokemon.SIZE + 0x12, 2},

    -- skip mail for now

    ballCapsule   = {BoxPokemon.SIZE + 0x4C, Array:extend(8, 3)}
})

function PartyPokemon:encrypt()
    return self.data:encrypt(self.boxPokemon.metadata.personality, BoxPokemon.SIZE, PartyPokemon.SIZE)
end
PartyPokemon.decrypt = PartyPokemon.encrypt -- alias for readability

function PartyPokemon:from_node(mem_node)
    local addr = mem_node:get_address()
    if not addr then
        return false
    end

    local partymon = PartyPokemon:new(Data:new(memory.readbyterange(addr, PartyPokemon.SIZE)))
    if not partymon then
        return false
    end
    
    if partymon.boxPokemon.metadata.boxDecrypted == 0 then
        local boxmon = BoxPokemon:new(partymon.boxPokemon:decrypt())
        if not boxmon then
            return false
        end
        partymon.boxPokemon = boxmon
    end

    if partymon.boxPokemon.metadata.partyDecrypted == 0 then
        partymon = PartyPokemon:new(partymon:decrypt())
        if not partymon then
            return false
        end
    end

    partymon.node = mem_node
    return partymon
end

function PartyPokemon:write_to_memory(addr)
    if not addr then
        if not self.node then
            Error("Attempt to write to memory without an address.")
        end

        addr = self.node:get_address()
        if not addr then
            return false
        end
    end

    if not self.boxPokemon:write_to_memory(addr) then
        return false
    end

    local party_data = self.data
    if self.boxPokemon.metadata.partyDecrypted == 0 then
        party_data = self:encrypt()
    end
    party_data:write_to_memory(addr + BoxPokemon.SIZE, BoxPokemon.SIZE, PartyPokemon.SIZE)

    return true
end

return {
    Metadata = Metadata,
    BoxPokemon = BoxPokemon,
    PartyPokemon = PartyPokemon,
}