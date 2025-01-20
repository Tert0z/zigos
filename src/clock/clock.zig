const assert = @import("std").debug.assert;

const ACPUCTRL_ADDR = 0x00FD1A0060;

pub const ACPUCTRL = packed struct {
    src_sel: u3,
    _reserved: u5,
    src_div: u6,
    _reserved2: u10,
    clk_full: u1,
    clk_half: u1,
    _reserved3: u38,

    comptime {
        assert(@sizeOf(ACPUCTRL) == 64 / 8);
    }

    pub fn init() *ACPUCTRL {
        return @ptrFromInt(ACPUCTRL_ADDR);
    }
};
