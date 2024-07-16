const uart = @import("uart/uart.zig");
const std = @import("std");

var buf: [1000]u8 = undefined;
var console: *uart.Console = undefined;

pub fn kmain() noreturn {
    var c = uart.Console.init(0x04140000);
    console = &c;

    run() catch |err| {
        const print = std.fmt.bufPrint(&buf, "Error: {}\n", .{err}) catch unreachable;
        console.write(print);
    };
    while (true) {}
    unreachable;
}

extern const interrupt_handler_asm: u32;

const CSRRegister = packed struct {};

pub fn run() !void {
    console.write("Hello, world!\n\r");
    var val: u64 = undefined;
    asm volatile (
        \\ mrs %[val], SCTLR_EL3
        : [val] "=r" (val),
    );
    const print = std.fmt.bufPrint(&buf, "SCTLR_EL1: {x}\n", .{val}) catch unreachable;
    console.write(print);
}
