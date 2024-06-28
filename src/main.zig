const uart = @import("uart/uart.zig");
const std = @import("std");
const sd = @import("sd/sd.zig");
const sbi = @import("sbi/sbi.zig");
const interrupt = @import("interrupts/registers.zig");
const debug = @import("debug/debug.zig");
const time = @import("timer/timer.zig");

var buf: [1000]u8 = undefined;
var console: *uart.Console = undefined;

//#define PLAT_CONSOLE_BAUDRATE 115200
//#define PLAT_UART_CLK_IN_HZ 25000000
//	int baudrate = baud_rate;
//int uart_clock = uart_clk;

//int divisor = uart_clock / (16 * baudrate);

//uart->lcr = uart->lcr | UART_LCR_DLAB | UART_LCR_8N1;
//asm (""::: "memory");
//uart->dll = divisor & 0xff;
//asm (""::: "memory");
//uart->dlm = (divisor >> 8) & 0xff;
//asm (""::: "memory");
//uart->lcr = uart->lcr & (~UART_LCR_DLAB);
//asm (""::: "memory");
//uart->ier = 0;
//asm (""::: "memory");
//uart->mcr = UART_MCRVAL;
//asm (""::: "memory");
//uart->fcr = UART_FCR_DEFVAL;
//asm (""::: "memory");
//uart->lcr = 3;

pub fn kmain() noreturn {
    const setup: *volatile u32 = @ptrFromInt(0x0300_1084);
    var setting = setup.*;
    const mask: u32 = 0x7;
    setting &= ~mask;
    setting |= 0x01;
    setup.* = setting;
    var c = uart.Console.init(0x041C_0000);
    console = &c;

    run() catch |err| {
        const print = std.fmt.bufPrint(&buf, "Error: {}\n", .{err}) catch unreachable;
        console.write(print);
    };
    while (true) {}
    unreachable;
}

extern var interrupt_handler_asm: u64;
extern var start_hart: u64;
extern var _h2_sp: u64;
extern var _h3_sp: u64;
extern var _h4_sp: u64;

pub fn run() !void {
    console.write("Hello, world!\n");

    const mmc = sd.Sd.init(0x0431_0000);
    var timer: u64 = time.read();
    const print = try std.fmt.bufPrint(&buf, "timer: {}\n\r", .{mmc});
    console.write(print);

    asm volatile (
        \\ csrw stvec, %[handler]
        :
        : [handler] "r" (@intFromPtr(&interrupt_handler_asm)),
    );

    var sstatus = interrupt.sstatus.read();
    const print2 = try std.fmt.bufPrint(&buf, "mideleg: {}\n\r", .{sstatus});
    console.write(print2);
    sstatus.sie = 1;
    sstatus.write();

    var sie = interrupt.sie.read();
    sie.stie = 1;
    sie.ssie = 1;
    sie.write();

    timer = time.read();
    //switch_to_user_mode();
    try sbi.sbi_set_timer(timer + 900000);
    try sbi.HSM.start_hart(2, @intFromPtr(&start_hart), @intFromPtr(&_h2_sp));
    try sbi.HSM.start_hart(3, @intFromPtr(&start_hart), @intFromPtr(&_h3_sp));
    try sbi.HSM.start_hart(4, @intFromPtr(&start_hart), @intFromPtr(&_h4_sp));

    var counter: u32 = 0;
    while (true) {
        var a: u32 = 0;
        const print3 = try std.fmt.bufPrint(&buf, "smode mode counter: {}\n\r", .{counter});
        console.write(print3);
        counter += 1;
        while (true) {
            a += 1;
            if (a == 200000000) break;
        }
    }
}

fn switch_to_user_mode() void {
    var sstatus = interrupt.sstatus.read();
    sstatus.spp = 0;
    sstatus.write();
    asm volatile (
        \\ csrw sepc, %[user_mode]
        \\ sret
        :
        : [user_mode] "r" (&user_mode),
    );
}

export fn other_hart(hartid: u64) void {
    while (true) {
        console.write("other hart inner loop\r\n");
        const id: u8 = @intCast(hartid);
        console.writeByte('0' + id);
        var a: u32 = 0;
        while (true) {
            a += 1;
            if (a == 300000000 + hartid * 100000) break;
        }
    }
}

fn user_mode() !void {
    var counter: u32 = 0;
    while (true) {
        var a: u32 = 0;
        const print3 = try std.fmt.bufPrint(&buf, "user mode counter: {}\n\r", .{counter});
        console.write(print3);
        counter += 1;
        while (true) {
            a += 1;
            if (a == 100000000) break;
        }
        asm volatile (
            \\ ecall
        );
    }
}

const err_str = "error";
var intGlobal: u32 = 0;
var ibuf: [1000]u8 = undefined;
export fn interrupt_handler() void {
    intGlobal += 1;
    var print = std.fmt.bufPrint(&ibuf, "Interrupt: {}\n\r", .{intGlobal}) catch {
        debug.hang();
        return;
    };
    console.write(print);
    const timer: u64 = time.read();

    //const sstatus = interrupt.sstatus.read();
    //_ = sstatus;
    const scause = interrupt.scause.read();
    if (scause.interrupt == 0) {}

    print = std.fmt.bufPrint(&ibuf, "Interrupt, scause: {}\n\r", .{scause}) catch {
        debug.hang();
        return;
    };
    console.write(print);
    const new_value = timer + 10000000;

    //sip.ssip = 0;
    //sip.write();
    //var sepc: u64 = 0;
    //asm volatile (
    //\\ csrr %[sepc], sepc
    //: [sepc] "=r" (sepc),
    //);
    //sepc += 4;
    //asm volatile (
    //\\ csrw sepc, %[sepc]
    //: [sepc] "=r" (sepc),
    //);

    sbi.sbi_set_timer(new_value) catch {
        debug.hang();
        return;
    };

    print = std.fmt.bufPrint(&ibuf, "Interrupt timer set: {}\n\r", .{new_value}) catch unreachable;
    console.write(print);
    return;
}
