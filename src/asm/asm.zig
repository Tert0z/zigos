pub fn read_system_reg(comptime reg: []const u8) u64 {
    var value: u64 = undefined;

    asm volatile ("mrs %[value], " ++ reg
        : [value] "=r" (value),
    );
    return value;
}

pub fn write_system_reg(comptime reg: []const u8, value: u64) void {
    asm volatile ("msr " ++ reg ++ ", %[value]"
        :
        : [value] "r" (value),
    );
}
