const std = @import("std");
const print = std.debug.print;

const crc32eth_table = [256]u32{
    0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
    0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988, 0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
    0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de, 0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
    0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec, 0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
    0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172, 0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
    0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940, 0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
    0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
    0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924, 0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
    0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
    0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
    0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e, 0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
    0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
    0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
    0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0, 0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
    0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
    0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
    0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a, 0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
    0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
    0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
    0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc, 0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
    0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
    0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
    0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236, 0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
    0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
    0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
    0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38, 0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
    0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
    0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
    0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2, 0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
    0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
    0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
    0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94, 0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
};

const crc32aut_table = [256]u32{
    0x00000000, 0x30850ff5, 0x610a1fea, 0x518f101f, 0xc2143fd4, 0xf2913021, 0xa31e203e, 0x939b2fcb,
    0x159615f7, 0x25131a02, 0x749c0a1d, 0x441905e8, 0xd7822a23, 0xe70725d6, 0xb68835c9, 0x860d3a3c,
    0x2b2c2bee, 0x1ba9241b, 0x4a263404, 0x7aa33bf1, 0xe938143a, 0xd9bd1bcf, 0x88320bd0, 0xb8b70425,
    0x3eba3e19, 0x0e3f31ec, 0x5fb021f3, 0x6f352e06, 0xfcae01cd, 0xcc2b0e38, 0x9da41e27, 0xad2111d2,
    0x565857dc, 0x66dd5829, 0x37524836, 0x07d747c3, 0x944c6808, 0xa4c967fd, 0xf54677e2, 0xc5c37817,
    0x43ce422b, 0x734b4dde, 0x22c45dc1, 0x12415234, 0x81da7dff, 0xb15f720a, 0xe0d06215, 0xd0556de0,
    0x7d747c32, 0x4df173c7, 0x1c7e63d8, 0x2cfb6c2d, 0xbf6043e6, 0x8fe54c13, 0xde6a5c0c, 0xeeef53f9,
    0x68e269c5, 0x58676630, 0x09e8762f, 0x396d79da, 0xaaf65611, 0x9a7359e4, 0xcbfc49fb, 0xfb79460e,
    0xacb0afb8, 0x9c35a04d, 0xcdbab052, 0xfd3fbfa7, 0x6ea4906c, 0x5e219f99, 0x0fae8f86, 0x3f2b8073,
    0xb926ba4f, 0x89a3b5ba, 0xd82ca5a5, 0xe8a9aa50, 0x7b32859b, 0x4bb78a6e, 0x1a389a71, 0x2abd9584,
    0x879c8456, 0xb7198ba3, 0xe6969bbc, 0xd6139449, 0x4588bb82, 0x750db477, 0x2482a468, 0x1407ab9d,
    0x920a91a1, 0xa28f9e54, 0xf3008e4b, 0xc38581be, 0x501eae75, 0x609ba180, 0x3114b19f, 0x0191be6a,
    0xfae8f864, 0xca6df791, 0x9be2e78e, 0xab67e87b, 0x38fcc7b0, 0x0879c845, 0x59f6d85a, 0x6973d7af,
    0xef7eed93, 0xdffbe266, 0x8e74f279, 0xbef1fd8c, 0x2d6ad247, 0x1defddb2, 0x4c60cdad, 0x7ce5c258,
    0xd1c4d38a, 0xe141dc7f, 0xb0cecc60, 0x804bc395, 0x13d0ec5e, 0x2355e3ab, 0x72daf3b4, 0x425ffc41,
    0xc452c67d, 0xf4d7c988, 0xa558d997, 0x95ddd662, 0x0646f9a9, 0x36c3f65c, 0x674ce643, 0x57c9e9b6,
    0xc8df352f, 0xf85a3ada, 0xa9d52ac5, 0x99502530, 0x0acb0afb, 0x3a4e050e, 0x6bc11511, 0x5b441ae4,
    0xdd4920d8, 0xedcc2f2d, 0xbc433f32, 0x8cc630c7, 0x1f5d1f0c, 0x2fd810f9, 0x7e5700e6, 0x4ed20f13,
    0xe3f31ec1, 0xd3761134, 0x82f9012b, 0xb27c0ede, 0x21e72115, 0x11622ee0, 0x40ed3eff, 0x7068310a,
    0xf6650b36, 0xc6e004c3, 0x976f14dc, 0xa7ea1b29, 0x347134e2, 0x04f43b17, 0x557b2b08, 0x65fe24fd,
    0x9e8762f3, 0xae026d06, 0xff8d7d19, 0xcf0872ec, 0x5c935d27, 0x6c1652d2, 0x3d9942cd, 0x0d1c4d38,
    0x8b117704, 0xbb9478f1, 0xea1b68ee, 0xda9e671b, 0x490548d0, 0x79804725, 0x280f573a, 0x188a58cf,
    0xb5ab491d, 0x852e46e8, 0xd4a156f7, 0xe4245902, 0x77bf76c9, 0x473a793c, 0x16b56923, 0x263066d6,
    0xa03d5cea, 0x90b8531f, 0xc1374300, 0xf1b24cf5, 0x6229633e, 0x52ac6ccb, 0x03237cd4, 0x33a67321,
    0x646f9a97, 0x54ea9562, 0x0565857d, 0x35e08a88, 0xa67ba543, 0x96feaab6, 0xc771baa9, 0xf7f4b55c,
    0x71f98f60, 0x417c8095, 0x10f3908a, 0x20769f7f, 0xb3edb0b4, 0x8368bf41, 0xd2e7af5e, 0xe262a0ab,
    0x4f43b179, 0x7fc6be8c, 0x2e49ae93, 0x1ecca166, 0x8d578ead, 0xbdd28158, 0xec5d9147, 0xdcd89eb2,
    0x5ad5a48e, 0x6a50ab7b, 0x3bdfbb64, 0x0b5ab491, 0x98c19b5a, 0xa84494af, 0xf9cb84b0, 0xc94e8b45,
    0x3237cd4b, 0x02b2c2be, 0x533dd2a1, 0x63b8dd54, 0xf023f29f, 0xc0a6fd6a, 0x9129ed75, 0xa1ace280,
    0x27a1d8bc, 0x1724d749, 0x46abc756, 0x762ec8a3, 0xe5b5e768, 0xd530e89d, 0x84bff882, 0xb43af777,
    0x191be6a5, 0x299ee950, 0x7811f94f, 0x4894f6ba, 0xdb0fd971, 0xeb8ad684, 0xba05c69b, 0x8a80c96e,
    0x0c8df352, 0x3c08fca7, 0x6d87ecb8, 0x5d02e34d, 0xce99cc86, 0xfe1cc373, 0xaf93d36c, 0x9f16dc99,
};

const crc_params = struct {
    start: u32,
    final: u32,
    polynomial: u32, // in normal notation
    koopman: ?u32, // in koopman (reversed) notation
    check: u32,
    magic: u32,
    in_reflected: bool,
    out_reflected: bool,
};

const crc32_ethernet = crc_params{
    .start = 0xFFFFFFFF,
    .final = 0xFFFFFFFF,
    .polynomial = 0x04C11DB7,
    .koopman = null,
    .check = 0xCBF43926,
    .magic = 0xDEBB20E3,
    .in_reflected = true,
    .out_reflected = true,
};

const crc32_autosar = crc_params{
    .start = 0xFFFFFFFF,
    .final = 0xFFFFFFFF,
    .polynomial = 0xF4ACFB13,
    .koopman = 0xFA567D89,
    .check = 0x1697D06A,
    .magic = 0x904CDDBF,
    .in_reflected = true,
    .out_reflected = true,
};

fn table32reversed(p: crc_params) [256]u32 {
    var table: [256]u32 = undefined;

    // mirror polinomial, since it is in normal form
    const rev_poly = reflect(u32, p.polynomial);

    for (0..256) |byte| {
        // get msb of current remainder
        var crc = @as(u32, @intCast(byte));

        for (0..8) |_| {
            if ((crc & 1) != 0) {
                // if msbit is 1, pop msbit and divide (xor) by poly
                crc >>= 1;
                crc ^= rev_poly;
            } else {
                // if msbit is 0, just pop msbit
                crc >>= 1;
            }
        }

        // save crc for current remainder
        table[byte] = crc;
    }
    return table;
}

fn table32normal(p: crc_params) [256]u32 {
    var table: [256]u32 = undefined;

    for (0..256) |byte| {
        // get msb of current remainder
        var crc = @as(u32, @intCast(byte)) << 24;
        for (0..8) |_| {
            if ((crc & (1 << 31)) != 0) {
                // if msbit is 1, pop msbit and divide (xor) by poly
                crc <<= 1;
                crc ^= p.polynomial;
            } else {
                // if msbit i 0, just pop msbit
                crc <<= 1;
            }
        }

        // save crc for current remainder
        table[byte] = crc;
    }
    return table;
}
test "verify table generation" {
    const t32r = table32reversed(crc32_ethernet);
    try std.testing.expectEqualSlices(u32, &crc32eth_table, &t32r);

    const t32a = table32reversed(crc32_autosar);
    try std.testing.expectEqualSlices(u32, &crc32aut_table, &t32a);
}

fn crc32SlowLittleEndian(data: []const u8, p: crc_params) u32 {
    // set starting value of register
    var crc: u32 = p.start;

    // for each byte of data
    for (data) |b| {
        // xor byte with msb of current register
        crc = crc ^ (@as(u32, reflect(u8, b)) << 24);
        // for each bit of the msb byte of the register
        for (0..8) |_| {
            if (crc & (1 << 31) != 0) {
                // if msbit is 1, pop msbit and divide (xor) by poly
                crc <<= 1;
                crc ^= p.polynomial;
            } else {
                // if msbit i 0, just pop msbit
                crc <<= 1;
            }
        }
    }

    // xor with final value
    crc ^= p.final;

    // reflect final value
    return reflect(u32, crc);
}

// when using the little endian algo, data need not to be mirrored, since the
// table which provides remainder is already computed using the mirrored polynomial
fn crc32FastLittleEndian(data: []const u8, p: crc_params) u32 {
    // assign crc register initial value
    var crc: u32 = p.start;
    for (data) |b| {
        // take msb (little endian)
        crc = crc ^ @as(u32, b);
        // find position in table by taking msb
        const pos = @as(usize, crc & 0xFF);
        // remove msb from crc (not used for crc calc)
        crc >>= 8;
        // xor table loookup with crc
        crc ^= crc32eth_table[pos];
    }

    // xor crc with exit value
    return crc ^ p.final;
}

fn temp(data: []const u8, p: crc_params) u32 {
    // assign crc register initial value
    var crc: u32 = 0;
    for (data) |b| {
        // take msb (little endian)
        const msb = crc ^ @as(u32, b);
        // find position in table by taking msb
        const pos = @as(usize, msb & 0xFF);
        // remove msb from crc (not used for crc calc)
        crc >>= 8;
        // xor table loookup with crc
        crc ^= crc32eth_table[pos];
    }

    // xor crc with exit value
    return crc ^ p.final;
}

fn crc32SlowBigEndian(data: []const u8, p: crc_params) u32 {
    // set starting value of register
    var crc: u32 = p.start;

    // for each byte of data
    for (data) |b| {
        // xor byte with msb of current register
        crc = crc ^ (@as(u32, b));
        // for each bit of the msb byte of the register
        for (0..8) |_| {
            if (crc & 1 != 0) {
                // if msbit is 1, pop msbit and divide (xor) by poly
                crc >>= 1;
                crc ^= reflect(u32, p.polynomial);
            } else {
                // if msbit i 0, just pop msbit
                crc >>= 1;
            }
        }
    }

    // xor with final value
    crc ^= p.final;
    return crc;
}

test "fast little endian" {
    const input = "123456789";

    // ethernet
    const crc_eth = crc32FastLittleEndian(input, crc32_ethernet);
    try std.testing.expectEqual(crc_eth, crc32_ethernet.check);

    const crc_empty_eth = crc32FastLittleEndian("", crc32_ethernet);
    const crc_empty_data_eth: *const [4]u8 = @ptrCast(&crc_empty_eth);
    const magic_eth = crc32FastLittleEndian(crc_empty_data_eth, crc32_ethernet) ^ crc32_ethernet.start;
    try std.testing.expectEqual(magic_eth, crc32_ethernet.magic);

    // autosar
    // const crc_aut = temp(input, crc32_autosar);
    // try std.testing.expectEqual(crc_aut, crc32_autosar.check);

    // const crc_empty_aut = temp("", crc32_autosar);
    // const crc_empty_data_aut: *const [4]u8 = @ptrCast(&crc_empty_aut);
    // const magic_aut = temp(crc_empty_data_aut, crc32_autosar) ^ crc32_autosar.start;
    // try std.testing.expectEqual(magic_aut, crc32_autosar.magic);
}

test "ethernet" {
    const tests = [7]struct {
        input: []const u8,
        output: u32,
    }{ .{
        .input = &[_]u8{ 0, 0, 0, 0 },
        .output = 0x2144DF1C,
    }, .{
        .input = &[_]u8{ 0xf2, 0x01, 0x83 },
        .output = 0x24AB9D77,
    }, .{
        .input = &[_]u8{ 0x0f, 0xaa, 0x00, 0x55 },
        .output = 0xB6C9B287,
    }, .{
        .input = &[_]u8{ 0x00, 0xff, 0x55, 0x11 },
        .output = 0x32A06212,
    }, .{
        .input = &[_]u8{ 0x33, 0x22, 0x55, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff },
        .output = 0xB0AE863D,
    }, .{
        .input = &[_]u8{ 0x92, 0x6b, 0x55 },
        .output = 0x9CDEA29B,
    }, .{
        .input = &[_]u8{ 0xff, 0xff, 0xff, 0xff },
        .output = 0xFFFFFFFF,
    } };

    for (tests) |t| {
        try std.testing.expectEqual(t.output, crc32FastLittleEndian(t.input, crc32_ethernet));
    }
}

test "autosar" {
    const tests = [7]struct {
        input: []const u8,
        output: u32,
    }{ .{
        .input = &[_]u8{ 0, 0, 0, 0 },
        .output = 0x6FB32240,
    }, .{
        .input = &[_]u8{ 0xf2, 0x01, 0x83 },
        .output = 0x4F721A25,
    }, .{
        .input = &[_]u8{ 0x0f, 0xaa, 0x00, 0x55 },
        .output = 0x20662DF8,
    }, .{
        .input = &[_]u8{ 0x00, 0xff, 0x55, 0x11 },
        .output = 0x9BD7996E,
    }, .{
        .input = &[_]u8{ 0x33, 0x22, 0x55, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff },
        .output = 0xA65A343D,
    }, .{
        .input = &[_]u8{ 0x92, 0x6b, 0x55 },
        .output = 0xEE688A78,
    }, .{
        .input = &[_]u8{ 0xff, 0xff, 0xff, 0xff },
        .output = 0xFFFFFFFF,
    } };

    for (tests) |t| {
        try std.testing.expectEqual(t.output, crc32SlowLittleEndian(t.input, crc32_autosar));
    }
}

test "slow little endian" {
    const input = "123456789";

    // ethernet
    const crc_eth = crc32SlowLittleEndian(input, crc32_ethernet);
    try std.testing.expectEqual(crc_eth, crc32_ethernet.check);

    const crc_empty_eth = crc32SlowLittleEndian("", crc32_ethernet);
    const crc_empty_data_eth: *const [4]u8 = @ptrCast(&crc_empty_eth);
    const magic_eth = crc32SlowLittleEndian(crc_empty_data_eth, crc32_ethernet) ^ crc32_ethernet.start;
    try std.testing.expectEqual(magic_eth, crc32_ethernet.magic);

    // autosar
    const crc_aut = crc32SlowLittleEndian(input, crc32_autosar);
    try std.testing.expectEqual(crc_aut, crc32_autosar.check);

    const crc_empty_aut = crc32SlowLittleEndian("", crc32_autosar);
    const crc_empty_data_aut: *const [4]u8 = @ptrCast(&crc_empty_aut);
    const magic_aut = crc32SlowLittleEndian(crc_empty_data_aut, crc32_autosar) ^ crc32_autosar.start;
    try std.testing.expectEqual(magic_aut, crc32_autosar.magic);
}

test "slow big endian" {
    const input = "123456789";

    // ethernet
    const crc_eth = crc32SlowBigEndian(input, crc32_ethernet);
    try std.testing.expectEqual(crc_eth, crc32_ethernet.check);

    const crc_empty_eth = crc32SlowBigEndian("", crc32_ethernet);
    const crc_empty_data_eth: *const [4]u8 = @ptrCast(&crc_empty_eth);
    const magic_eth = crc32SlowBigEndian(crc_empty_data_eth, crc32_ethernet) ^ crc32_ethernet.start;
    try std.testing.expectEqual(magic_eth, crc32_ethernet.magic);

    // autosar
    const crc_aut = crc32SlowBigEndian(input, crc32_autosar);
    try std.testing.expectEqual(crc_aut, crc32_autosar.check);

    const crc_empty_aut = crc32SlowBigEndian("", crc32_autosar);
    const crc_empty_data_aut: *const [4]u8 = @ptrCast(&crc_empty_aut);
    const magic_aut = crc32SlowBigEndian(crc_empty_data_aut, crc32_autosar) ^ crc32_autosar.start;
    try std.testing.expectEqual(magic_aut, crc32_autosar.magic);
}

fn reflect(comptime T: type, value: T) T {
    var result: T = 0;
    var num = value;
    for (@sizeOf(T) * 8) |_| {
        result <<= 1;
        result |= num & 1;
        num >>= 1;
    }
    return result;
}

test "reflect" {
    try std.testing.expectEqual(0x80, reflect(u8, 1));
    try std.testing.expectEqual(0x8000_0000, reflect(u32, 1));
}
