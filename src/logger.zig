const std = @import("std");
const uart = @import("uart/uart.zig");

extern var _sp: u32;
export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ mov sp, %[sp]
        //\\ ldr x1, =vector_table_jumps
        //\\ msr VBAR_EL1, x1
        \\ bl %[lmain]
        :
        : [lmain] "i" (&lmain),
          [sp] "r" (&_sp),
    );
}

fn lmain() void {
    var console = uart.Console.init(0xFF00_0000);
    var buf: [1000]u8 = undefined;

    var c: u64 = 0;
    while (true) {
        c += 1;
        console.write(std.fmt.bufPrint(&buf, "Read r5: {}\n\r", .{c}) catch unreachable);

        for (0..100000) |_| {
            asm volatile ("nop");
        }
    }
}
