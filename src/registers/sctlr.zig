const asm_helpers = @import("asm_helpers");

pub const SCTLR = packed struct {
    mmu_enable: u1,
    alignment_check: u1,
    data_cache_enable: u1,
    stack_pointer_alignment_check: u1,
    _reserved: u8,
    instruction_cache_enable: u1,
    __: u51,

    pub fn init() SCTLR {
        return @bitCast(asm_helpers.read_system_reg("SCTLR_EL1"));
    }

    pub fn write(self: SCTLR) void {
        asm_helpers.write_system_reg("SCTLR_EL1", @bitCast(self));
    }
};
