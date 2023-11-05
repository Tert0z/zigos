const main = @import("main.zig");

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ la sp, _sp
        \\ call %[kmain]
        :
        : [kmain] "i" (&main.kmain),
    );
    while (true) {}
}
