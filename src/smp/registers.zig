const asm_helpers = @import("asm_helpers");

pub const MPIDR = packed struct {
    Aff0: u8 = 0,
    Aff1: u8 = 0,
    Aff2: u8 = 0,
    MT: u1 = 0,
    _: u5 = 0,
    U: u1 = 0,
    __: u1 = 0,
    Aff3: u8 = 0,
    ___: u24 = 0,

    pub fn init() MPIDR {
        const val = asm_helpers.read_system_reg("MPIDR_EL1");
        return @bitCast(val);
    }
};
