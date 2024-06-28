const main = @import("main.zig");

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ la sp, _h1_sp
        \\ call %[kmain]
        \\ wfi
        :
        : [kmain] "i" (&main.kmain),
    );
}
