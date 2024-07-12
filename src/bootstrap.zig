const main = @import("main.zig");

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ ldr x1, =_sp
        \\ mov sp, x1
        \\ bl %[kmain]
        :
        : [kmain] "i" (&main.kmain),
    );
}
