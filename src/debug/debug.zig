pub inline fn breakpoint() void {
    asm volatile ("ebreak");
}

pub inline fn hang() void {
    asm volatile ("wfi");
}
