local Data = require("LuaDS.Data")
local Bitwise = require("LuaDS.Bitwise")

-- Gen 4 Pokemon character encoding table.
-- Maps 2-byte encoded values to UTF-8 strings.
-- 0x0000 is the null character and 0xFFFF is the string terminator; both are handled externally.
-- Pocket symbol entries 0x113-0x11A are omitted.
local ENCODING = {
    [0x001] = "　",

    -- Hiragana
    [0x002] = "ぁ", [0x003] = "あ", [0x004] = "ぃ", [0x005] = "い",
    [0x006] = "ぅ", [0x007] = "う", [0x008] = "ぇ", [0x009] = "え",
    [0x00A] = "ぉ", [0x00B] = "お", [0x00C] = "か", [0x00D] = "が",
    [0x00E] = "き", [0x00F] = "ぎ",
    [0x010] = "く", [0x011] = "ぐ", [0x012] = "け", [0x013] = "げ",
    [0x014] = "こ", [0x015] = "ご", [0x016] = "さ", [0x017] = "ざ",
    [0x018] = "し", [0x019] = "じ", [0x01A] = "す", [0x01B] = "ず",
    [0x01C] = "せ", [0x01D] = "ぜ", [0x01E] = "そ", [0x01F] = "ぞ",
    [0x020] = "た", [0x021] = "だ", [0x022] = "ち", [0x023] = "ぢ",
    [0x024] = "っ", [0x025] = "つ", [0x026] = "づ", [0x027] = "て",
    [0x028] = "で", [0x029] = "と", [0x02A] = "ど", [0x02B] = "な",
    [0x02C] = "に", [0x02D] = "ぬ", [0x02E] = "ね", [0x02F] = "の",
    [0x030] = "は", [0x031] = "ば", [0x032] = "ぱ", [0x033] = "ひ",
    [0x034] = "び", [0x035] = "ぴ", [0x036] = "ふ", [0x037] = "ぶ",
    [0x038] = "ぷ", [0x039] = "へ", [0x03A] = "べ", [0x03B] = "ぺ",
    [0x03C] = "ほ", [0x03D] = "ぼ", [0x03E] = "ぽ", [0x03F] = "ま",
    [0x040] = "み", [0x041] = "む", [0x042] = "め", [0x043] = "も",
    [0x044] = "ゃ", [0x045] = "や", [0x046] = "ゅ", [0x047] = "ゆ",
    [0x048] = "ょ", [0x049] = "よ", [0x04A] = "ら", [0x04B] = "り",
    [0x04C] = "る", [0x04D] = "れ", [0x04E] = "ろ", [0x04F] = "わ",
    [0x050] = "を", [0x051] = "ん",

    -- Katakana
    [0x052] = "ァ", [0x053] = "ア", [0x054] = "ィ", [0x055] = "イ",
    [0x056] = "ゥ", [0x057] = "ウ", [0x058] = "ェ", [0x059] = "エ",
    [0x05A] = "ォ", [0x05B] = "オ", [0x05C] = "カ", [0x05D] = "ガ",
    [0x05E] = "キ", [0x05F] = "ギ",
    [0x060] = "ク", [0x061] = "グ", [0x062] = "ケ", [0x063] = "ゲ",
    [0x064] = "コ", [0x065] = "ゴ", [0x066] = "サ", [0x067] = "ザ",
    [0x068] = "シ", [0x069] = "ジ", [0x06A] = "ス", [0x06B] = "ズ",
    [0x06C] = "セ", [0x06D] = "ゼ", [0x06E] = "ソ", [0x06F] = "ゾ",
    [0x070] = "タ", [0x071] = "ダ", [0x072] = "チ", [0x073] = "ヂ",
    [0x074] = "ッ", [0x075] = "ツ", [0x076] = "ヅ", [0x077] = "テ",
    [0x078] = "デ", [0x079] = "ト", [0x07A] = "ド", [0x07B] = "ナ",
    [0x07C] = "ニ", [0x07D] = "ヌ", [0x07E] = "ネ", [0x07F] = "ノ",
    [0x080] = "ハ", [0x081] = "バ", [0x082] = "パ", [0x083] = "ヒ",
    [0x084] = "ビ", [0x085] = "ピ", [0x086] = "フ", [0x087] = "ブ",
    [0x088] = "プ", [0x089] = "ヘ", [0x08A] = "ベ", [0x08B] = "ペ",
    [0x08C] = "ホ", [0x08D] = "ボ", [0x08E] = "ポ", [0x08F] = "マ",
    [0x090] = "ミ", [0x091] = "ム", [0x092] = "メ", [0x093] = "モ",
    [0x094] = "ャ", [0x095] = "ヤ", [0x096] = "ュ", [0x097] = "ユ",
    [0x098] = "ョ", [0x099] = "ヨ", [0x09A] = "ラ", [0x09B] = "リ",
    [0x09C] = "ル", [0x09D] = "レ", [0x09E] = "ロ", [0x09F] = "ワ",
    [0x0A0] = "ヲ", [0x0A1] = "ン",

    -- Fullwidth digits
    [0x0A2] = "０", [0x0A3] = "１", [0x0A4] = "２", [0x0A5] = "３",
    [0x0A6] = "４", [0x0A7] = "５", [0x0A8] = "６", [0x0A9] = "７",
    [0x0AA] = "８", [0x0AB] = "９",

    -- Fullwidth uppercase
    [0x0AC] = "Ａ", [0x0AD] = "Ｂ", [0x0AE] = "Ｃ", [0x0AF] = "Ｄ",
    [0x0B0] = "Ｅ", [0x0B1] = "Ｆ", [0x0B2] = "Ｇ", [0x0B3] = "Ｈ",
    [0x0B4] = "Ｉ", [0x0B5] = "Ｊ", [0x0B6] = "Ｋ", [0x0B7] = "Ｌ",
    [0x0B8] = "Ｍ", [0x0B9] = "Ｎ", [0x0BA] = "Ｏ", [0x0BB] = "Ｐ",
    [0x0BC] = "Ｑ", [0x0BD] = "Ｒ", [0x0BE] = "Ｓ", [0x0BF] = "Ｔ",
    [0x0C0] = "Ｕ", [0x0C1] = "Ｖ", [0x0C2] = "Ｗ", [0x0C3] = "Ｘ",
    [0x0C4] = "Ｙ", [0x0C5] = "Ｚ",

    -- Fullwidth lowercase
    [0x0C6] = "ａ", [0x0C7] = "ｂ", [0x0C8] = "ｃ", [0x0C9] = "ｄ",
    [0x0CA] = "ｅ", [0x0CB] = "ｆ", [0x0CC] = "ｇ", [0x0CD] = "ｈ",
    [0x0CE] = "ｉ", [0x0CF] = "ｊ", [0x0D0] = "ｋ", [0x0D1] = "ｌ",
    [0x0D2] = "ｍ", [0x0D3] = "ｎ", [0x0D4] = "ｏ", [0x0D5] = "ｐ",
    [0x0D6] = "ｑ", [0x0D7] = "ｒ", [0x0D8] = "ｓ", [0x0D9] = "ｔ",
    [0x0DA] = "ｕ", [0x0DB] = "ｖ", [0x0DC] = "ｗ", [0x0DD] = "ｘ",
    [0x0DE] = "ｙ", [0x0DF] = "ｚ",

    -- Punctuation and symbols (fullwidth/Japanese set)
    [0x0E1] = "！", [0x0E2] = "？", [0x0E3] = "、", [0x0E4] = "。",
    [0x0E5] = "…", [0x0E6] = "・", [0x0E7] = "／", [0x0E8] = "「",
    [0x0E9] = "」", [0x0EA] = "『", [0x0EB] = "』", [0x0EC] = "（",
    [0x0ED] = "）", [0x0EE] = "♂", [0x0EF] = "♀",
    [0x0F0] = "＋", [0x0F1] = "ー", [0x0F2] = "×", [0x0F3] = "÷",
    [0x0F4] = "＝", [0x0F5] = "～", [0x0F6] = "：", [0x0F7] = "；",
    [0x0F8] = "．", [0x0F9] = "，", [0x0FA] = "♠", [0x0FB] = "♣",
    [0x0FC] = "♥", [0x0FD] = "♦", [0x0FE] = "★", [0x0FF] = "◎",

    -- More symbols
    [0x100] = "○", [0x101] = "□", [0x102] = "△", [0x103] = "◇",
    [0x104] = "＠", [0x105] = "♪", [0x106] = "％",
    [0x107] = "☀", [0x108] = "☁", [0x109] = "☂", [0x10A] = "☃",
    [0x10B] = "😑", [0x10C] = "☺", [0x10D] = "☹", [0x10E] = "😠",
    [0x10F] = "⤴",
    [0x110] = "⤵", [0x111] = "💤", [0x112] = "円",
    -- 0x113-0x11A: pocket symbols, omitted
    [0x11B] = "←", [0x11C] = "↑", [0x11D] = "↓", [0x11E] = "→",
    [0x11F] = "►",

    -- Half-width digits and letters (in-game "plain" ASCII equivalent)
    [0x120] = "＆",
    [0x121] = "0", [0x122] = "1", [0x123] = "2", [0x124] = "3",
    [0x125] = "4", [0x126] = "5", [0x127] = "6", [0x128] = "7",
    [0x129] = "8", [0x12A] = "9",
    [0x12B] = "A", [0x12C] = "B", [0x12D] = "C", [0x12E] = "D",
    [0x12F] = "E", [0x130] = "F", [0x131] = "G", [0x132] = "H",
    [0x133] = "I", [0x134] = "J", [0x135] = "K", [0x136] = "L",
    [0x137] = "M", [0x138] = "N", [0x139] = "O", [0x13A] = "P",
    [0x13B] = "Q", [0x13C] = "R", [0x13D] = "S", [0x13E] = "T",
    [0x13F] = "U", [0x140] = "V", [0x141] = "W", [0x142] = "X",
    [0x143] = "Y", [0x144] = "Z",
    [0x145] = "a", [0x146] = "b", [0x147] = "c", [0x148] = "d",
    [0x149] = "e", [0x14A] = "f", [0x14B] = "g", [0x14C] = "h",
    [0x14D] = "i", [0x14E] = "j", [0x14F] = "k", [0x150] = "l",
    [0x151] = "m", [0x152] = "n", [0x153] = "o", [0x154] = "p",
    [0x155] = "q", [0x156] = "r", [0x157] = "s", [0x158] = "t",
    [0x159] = "u", [0x15A] = "v", [0x15B] = "w", [0x15C] = "x",
    [0x15D] = "y", [0x15E] = "z",

    -- Extended Latin
    [0x15F] = "À",
    [0x160] = "Á", [0x161] = "Â", [0x162] = "Ã", [0x163] = "Ä",
    [0x164] = "Å", [0x165] = "Æ", [0x166] = "Ç", [0x167] = "È",
    [0x168] = "É", [0x169] = "Ê", [0x16A] = "Ë", [0x16B] = "Ì",
    [0x16C] = "Í", [0x16D] = "Î", [0x16E] = "Ï", [0x16F] = "Ð",
    [0x170] = "Ñ", [0x171] = "Ò", [0x172] = "Ó", [0x173] = "Ô",
    [0x174] = "Õ", [0x175] = "Ö", [0x176] = "×", [0x177] = "Ø",
    [0x178] = "Ù", [0x179] = "Ú", [0x17A] = "Û", [0x17B] = "Ü",
    [0x17C] = "Ý", [0x17D] = "Þ", [0x17E] = "ß", [0x17F] = "à",
    [0x180] = "á", [0x181] = "â", [0x182] = "ã", [0x183] = "ä",
    [0x184] = "å", [0x185] = "æ", [0x186] = "ç", [0x187] = "è",
    [0x188] = "é", [0x189] = "ê", [0x18A] = "ë", [0x18B] = "ì",
    [0x18C] = "í", [0x18D] = "î", [0x18E] = "ï", [0x18F] = "ð",
    [0x190] = "ñ", [0x191] = "ò", [0x192] = "ó", [0x193] = "ô",
    [0x194] = "õ", [0x195] = "ö", [0x196] = "÷", [0x197] = "ø",
    [0x198] = "ù", [0x199] = "ú", [0x19A] = "û", [0x19B] = "ü",
    [0x19C] = "ý", [0x19D] = "þ", [0x19E] = "ÿ", [0x19F] = "Œ",
    [0x1A0] = "œ", [0x1A1] = "Ş", [0x1A2] = "ş", [0x1A3] = "ª",
    [0x1A4] = "º", [0x1A5] = "er",[0x1A6] = "re",[0x1A7] = "r",
    [0x1A8] = "$", -- Pokemon Dollar; no standard Unicode equivalent
    [0x1A9] = "¡", [0x1AA] = "¿", [0x1AB] = "!", [0x1AC] = "?",
    [0x1AD] = ",", [0x1AE] = ".", [0x1AF] = "…",

    -- Punctuation (half-width/ASCII set)
    [0x1B0] = "･", [0x1B1] = "/",
    [0x1B2] = "'", [0x1B3] = "'", [0x1B4] = "\"", [0x1B5] = "\"",
    [0x1B6] = "„", [0x1B7] = "«", [0x1B8] = "»",
    [0x1B9] = "(", [0x1BA] = ")",
    [0x1BB] = "♂", [0x1BC] = "♀",
    [0x1BD] = "+", [0x1BE] = "-", [0x1BF] = "*",
    [0x1C0] = "#", [0x1C1] = "=", [0x1C2] = "&", [0x1C3] = "~",
    [0x1C4] = ":", [0x1C5] = ";",
    [0x1C6] = "♠", [0x1C7] = "♣", [0x1C8] = "♥", [0x1C9] = "♦",
    [0x1CA] = "★", [0x1CB] = "◎", [0x1CC] = "○", [0x1CD] = "□",
    [0x1CE] = "△", [0x1CF] = "◇",
    [0x1D0] = "@", [0x1D1] = "♪", [0x1D2] = "%",
    [0x1D3] = "☀", [0x1D4] = "☁", [0x1D5] = "☂", [0x1D6] = "☃",
    [0x1D7] = "😑", [0x1D8] = "☺", [0x1D9] = "☹", [0x1DA] = "😠",
    [0x1DB] = "⤴", [0x1DC] = "⤵", [0x1DD] = "💤",
    [0x1DF] = "e",

    -- Special glyphs
    [0x1E0] = "PK", [0x1E1] = "MN",
    [0x1E8] = "°", [0x1E9] = "_", [0x1EA] = "＿",
    [0x1EB] = "․", [0x1EC] = "‥",
}
setmetatable(ENCODING, {__index = function(t, k) return "?" end})

-- In Gen 4, strings encode as 16-bit sequences terminating in 0xFFFF. Note that the encoding is NOT UTF-16, but is instead specific to Pokemon.
function Data:readstring(addr)
    local ret = {}
    local char_size = 16
    if self:read(addr, 2) == 0xF100 then
        char_size = 9
        addr = addr + 2
    end
    local offset = 0
    local buffer = 0
    local buffer_bits = 0
    while offset <= 20 and self:read(addr + offset, 2) ~= 0xFFFF do
        local char = self:read(addr + offset, 2)
        buffer = buffer + Bitwise.lshift(char, buffer_bits)
        buffer_bits = buffer_bits + (char_size == 9 and 15 or 16)
        while buffer_bits >= char_size do
            buffer_bits = buffer_bits - char_size
            local char_val = Bitwise.band(buffer, (2 ^ char_size) - 1)
            buffer = Bitwise.rshift(buffer, char_size)
            if char_val == 0x1FF then
                return ret
            end
            table.insert(ret, char_val)
        end
        offset = offset + 2
    end
    return ret
end
function Data.encode_string(data)
    local str = ""
    if data then
        for _, val in ipairs(data) do
            if val == 0 or val == 0xFFFF then
                break
            end
            local character = ENCODING[val]
            if string.byte(character) < 32 or string.byte(character) > 126 then
                str = str .. "_"
            else
                str = str .. character
            end
        end
    end
    return str
end

function Data:shuffle_blocks(permutation, offset, block_size)
    local ret = self:deep_copy()
    for i = 1, #permutation do
        ret:writebyterange(offset + (i - 1) * block_size, self:readbyterange(offset + permutation[i] * block_size, block_size))
    end
    return ret
end

function Data:unshuffle_blocks(permutation, offset, block_size)
    local ret = self:deep_copy()
    for i = 1, #permutation do
        ret:writebyterange(offset + permutation[i] * block_size, self:readbyterange(offset + (i - 1) * block_size, block_size))
    end
    return ret
end

-- Creates and returns a new table which is the current table en/decrypted. 
-- Is its own inverse, i.e. if you encrypt the same region using the same seed twice you get back the original version.
-- Implementation of this and the next function is largely copied from Emi's versus link ersatz. See https://projectpokemon.org/home/docs/gen-4/pkm-structure-r65/ for further info.
function Data:encrypt(seed, start_offset, end_offset)
	local prng = seed;
	-- Did you know Lua will coerce all literals to be at max 0xffffffff?
	-- This means if you do `% 0x100000000` you're actually doing `% 0xffffffff`
	-- This isn't a limitation of the math though, just the literal parsing
	local mod = 0xffffffff + 1
    local ret = self:deep_copy()
	for i = start_offset, end_offset-1, 2 do
		-- Multiplying by 0x41C64E6D without losing precision
		local next = (((0x41C6 * prng) % 0x100000) * 0x10000) % mod
		next = next + (0x4E6D * prng) % mod
		prng = (next + 0x6073) % mod

		local v = self:read(i, 2)
		v = Bitwise.bxor(v, Bitwise.rshift(prng, 16))
        ret:write(i, 2, v)
	end

    return ret
end
Data.decrypt = Data.encrypt -- alias for readability

function Data:checksum(start_offset, end_offset)
	local sum = 0
    if not start_offset then
        start_offset = 0
    end
    if not end_offset then
        end_offset = self.end_offset - self.start_offset
    end
    self:access_check(start_offset, end_offset - start_offset)
	for i = start_offset, end_offset - 1, 2 do
		sum = (sum + self:read(i, 2)) % 0x10000
	end
	return sum
end

return Data