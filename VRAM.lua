local Bitwise = require("LuaDS.Bitwise")
local Data = require("LuaDS.Data")
local Error = require("LuaDS.Error")

-- Emulated VRAM behavior to make manipulation of the game's VRAM as painless as possible.
local VRAM = {
    FLAGS_ADDR =   0x04000240,
    MAINBG_ADDR =  0x06000000,
    SUBBG_ADDR =   0x06200000,
    MAINOBJ_ADDR = 0x06400000,
    SUBOBJ_ADDR =  0x06600000,
    A = {
        ADDR = 0x06800000,
        SIZE =    0x20000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    B = {
        ADDR = 0x06820000,
        SIZE =    0x20000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    C = {
        ADDR = 0x06840000,
        SIZE =    0x20000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    D = {
        ADDR = 0x06860000,
        SIZE =    0x20000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    E = {
        ADDR = 0x06880000,
        SIZE =    0x10000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    F = {
        ADDR = 0x06890000,
        SIZE =     0x4000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    G = {
        ADDR = 0x06894000,
        SIZE =     0x4000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    H = {
        ADDR = 0x06898000,
        SIZE =     0x8000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
    I = {
        ADDR = 0x068a0000,
        SIZE =     0x4000,
        enabled = 0,
        ofs = 0,
        mst = 0
    },
}

function VRAM.read_flags(bank)
    local bank_index = string.byte(bank) - string.byte('A')
    if string.byte(bank) >= string.byte('H') then
        bank_index = bank_index + 1 -- Banks H and I are the 8th and 9th banks, but they're at indices 0x08 and 0x09 in the flags, rather than 0x07 and 0x08 as you might expect.
    end
    local bank_flag_addr = VRAM.FLAGS_ADDR + bank_index
    local flags = memory.readbyte(bank_flag_addr)

    local enabled = Bitwise.band(flags, 0x80) -- 0b10000000
    VRAM[bank].enabled = Bitwise.shift(enabled, ">>", 7)

    local ofs = Bitwise.band(flags, 0x18) -- 0b00011000
    VRAM[bank].ofs = Bitwise.shift(ofs, ">>", 3)

    local mst = Bitwise.band(flags, 0x07) -- 0b00000111
    VRAM[bank].mst = mst
end

function VRAM.write_flags(bank)
    local bank_index = string.byte(bank) - string.byte('A')
    if string.byte(bank) >= string.byte('H') then
        bank_index = bank_index + 1 -- See above.
    end
    local bank_flag_addr = VRAM.FLAGS_ADDR + bank_index

    local enabled = Bitwise.shift(VRAM[bank].enabled, "<<", 7)
    local ofs = Bitwise.shift(VRAM[bank].ofs, "<<", 3)
    local mst = VRAM[bank].mst

    local flags = enabled + ofs + mst
    memory.writebyte(bank_flag_addr, flags)
end

function VRAM.set_flags(bank, enabled, ofs, mst)
    VRAM[bank].enabled = enabled
    VRAM[bank].ofs = ofs
    VRAM[bank].mst = mst
    VRAM.write_flags(bank)
end

function VRAM.read_all_flags()
    for bank_index = 0, 8 do
        local bank = string.char(string.byte('A') + bank_index)
        VRAM.read_flags(bank)
    end
end

function VRAM.write_all_flags()
    for bank_index = 0, 8 do
        local bank = string.char(string.byte('A') + bank_index)
        VRAM.write_flags(bank)
    end
end

-- https://problemkaputt.de/gbatek-ds-memory-control-vram.htm
function VRAM.get_GPU_addr(bank)
    local ofs = VRAM[bank].ofs
    local ofs0 = Bitwise.band(ofs, 0x01) -- 0b00000001
    local ofs1 = Bitwise.band(ofs, 0x02) -- 0b00000010
    local mst = VRAM[bank].mst

    if mst == 0 then -- invisible to the GPU, in LCD mode.
        return nil

    elseif mst == 1 then
        if bank == 'A' or bank == 'B' or bank == 'C' or bank == 'D' then
            return 0x06000000 + (ofs * 0x20000)
        elseif bank == 'E' then
            return 0x06000000
        elseif bank == 'F' or bank == 'G' then
            return 0x06000000 + (ofs0 * 0x4000) + (ofs1 * 0x10000)
        elseif bank == 'H' then
            return 0x06200000 -- Engine B
        elseif bank == 'I' then
            return 0x06208000 -- Engine B
        end

    elseif mst == 2 then
        if bank == 'A' or bank == 'B' then
            return 0x06400000 + (ofs0 * 0x20000)
        elseif bank == 'C' or bank == 'D' then
            return 0x06000000 + (ofs0 * 0x20000)
        elseif bank == 'E' then
            return 0x06400000
        elseif bank == 'F' or bank == 'G' then
            return 0x06400000 + (ofs0 * 0x4000) + (ofs1 * 0x10000)
        elseif bank == 'H' then
            return nil -- Address unknown to me at the present moment.
        elseif bank == 'I' then
            return 0x06600000 -- Engine B
        end
    
    elseif mst == 3 then
        if bank == 'A' or bank == 'B' or bank == 'C' or bank == 'D' then
            return 0x06800000 + (ofs * 0x20000)
        elseif bank == 'E' then
            return 0x06880000
        elseif bank == 'F' or bank == 'G' then
            return 0x06880000 + (ofs0 * 0x4000) + (ofs1 * 0x10000)
        elseif bank == 'H' then
            return nil -- Unused mst for H
        elseif bank == 'I' then
            return nil -- Address unknown to me at the present moment.
        end

    elseif mst == 4 then
        if bank == 'A' or bank == 'B' then
            return nil -- Unused mst for A and B
        elseif bank == 'C' then
            return 0x06200000 -- Engine B
        elseif bank == 'D' then
            return 0x06600000 -- Engine B
        elseif bank == 'E' then
            return nil -- Address unknown to me at the present moment.
        elseif bank == 'F' or bank == 'G' then
            return nil -- Address unknown to me at the present moment.
        elseif bank == 'H' or bank == 'I' then
            return nil -- Unused mst for H and I
        end

    elseif mst == 5 then
        if bank == 'A' or bank == 'B' or bank == 'C' or bank == 'D' or bank == 'E' then
            return nil -- Unused mst for A, B, C, D, and E
        elseif bank == 'F' or bank == 'G' then
            return nil -- Address unknown to me at the present moment.
        elseif bank == 'H' or bank == 'I' then
            return nil -- Unused mst for H and I
        end
    end
end

VRAM.read_all_flags() -- Initialize the VRAM bank flags on script load.
VRAM.set_flags("D", 1, 3, 3) -- Enable Bank D with offset 3 and mst 3.

function VRAM.generate_texkey(addr, size) -- If size not defined, defaults to 0x3000
    if not size then
        size = 0x3000
    end
    local size_word = Bitwise.shift(size, "<<", 12)
    local addr_word = Bitwise.band(Bitwise.shift(addr, ">>", 3), 0x0000FFFF)

    return size_word + addr_word
end

function VRAM.decode_texkey(texkey)
    local size_word = Bitwise.band(texkey, 0x7fff0000)
    local size = Bitwise.shift(size_word, ">>", 12)

    local addr_word = Bitwise.band(texkey, 0x0000FFFF)
    local addr = Bitwise.shift(addr_word, "<<", 3)

    return {addr, size}
end

function VRAM.generate_plttkey(addr, size) -- If size not defined, defaults to 0x20
    if not size then
        size = 0x20
    end
    local size_word = Bitwise.shift(size, "<<", 13)
    local addr_word = Bitwise.band(Bitwise.shift(addr, ">>", 3), 0x0000FFFF)

    return size_word + addr_word
end

function VRAM.decode_plttkey(plttkey)
    local size_word = Bitwise.band(plttkey, 0x7ffe0000)
    local size = Bitwise.shift(size_word, ">>", 13)

    local addr_word = Bitwise.band(plttkey, 0x0000FFFF)
    local addr = Bitwise.shift(addr_word, "<<", 3)

    return {addr, size}
end

function VRAM.inject_sprite(sprite, tex_bank, tex_offset, pltt_bank, pltt_offset) -- Injects the texture and palette data of the given sprite into VRAM.
    if not sprite.texture or not sprite.palette then
        Error("Invalid sprite passed in for injection: missing texture or palette data.")
    end

    local tex_mst = VRAM[tex_bank].mst
    VRAM[tex_bank].mst = 0 -- set to LCD mode, so we can write it.
    VRAM.write_flags(tex_bank)

    local pltt_mst = VRAM[pltt_bank].mst
    VRAM[pltt_bank].mst = 0 -- set to LCD mode, so we can write it.
    VRAM.write_flags(pltt_bank)

    local tex_addr = VRAM[tex_bank].ADDR + tex_offset
    for i = 1, #sprite.texture do
        if not sprite.texture[i]:is_instance_of(Data) then
            Error("Invalid sprite passed in for injection: texture " .. i .. " not in Data format.")
        end
        sprite.texture[i]:write_to_memory(tex_addr)
        tex_addr = tex_addr + sprite.texture[i]:len()
    end
    tex_offset = tex_addr - VRAM[tex_bank]

    -- Under the hood, palette offsets are back-to-front, since all palette banks are in use by the game already.
    -- As such, we do this to minimize odds of collision.
    local pltt_addr = VRAM[pltt_bank].ADDR + VRAM[pltt_bank].SIZE - pltt_offset
    for i = 1, #sprite.palette do
        if not sprite.palette[i]:is_instance_of(Data) then
            Error("Invalid sprite passed in for injection: palette " .. i .. " not in Data format.")
        end
        pltt_addr = pltt_addr - sprite.palette[i]:len()
        sprite.palette[i]:write_to_memory(pltt_addr)
    end
    pltt_offset = VRAM[pltt_bank].ADDR + VRAM[pltt_bank].SiZE - pltt_addr

    VRAM[texbank].mst = tex_mst -- restore original mst
    VRAM.write_flags(texbank)

    VRAM[plttbank].mst = pltt_mst -- restore original mst
    VRAM.write_flags(plttbank)

    -- return the addresses immediately after our insertion ends, so the caller knows where to insert next.
    return {tex_offset, pltt_offset} 
end

return {
    VRAM = VRAM,
}