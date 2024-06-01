const uart = @import("uart/uart.zig");
const std = @import("std");
const sbi = @import("sbi/sbi.zig");
const interrupt = @import("interrupts/registers.zig");
const debug = @import("debug/debug.zig");
const time = @import("timer/timer.zig");

var buf: [1000]u8 = undefined;
var console: *uart.Console = undefined;

pub fn kmain() noreturn {
    var c = uart.Console.init(0x10000000);
    console = &c;

    run() catch |err| {
        const print = std.fmt.bufPrint(&buf, "Error: {}\n", .{err}) catch unreachable;
        console.write(print);
    };
    while (true) {}
    unreachable;
}

extern const interrupt_handler_asm: u32;

pub fn run() !void {
    console.write("Hello, world!\n");

    var timer: u64 = time.read();
    const print = try std.fmt.bufPrint(&buf, "timer: {x}\n\r", .{timer});
    console.write(print);

    asm volatile (
        \\ csrw stvec, %[handler]
        : [handler] "=r" (interrupt_handler_asm),
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
    try sbi.HSM.start_hart(2, interrupt_handler_asm);
    //try sbi.HSM.start_hart(3, @intFromPtr(&hart_entry2));
    //try sbi.HSM.start_hart(4, @intFromPtr(&hart_entry3));

    var counter: u32 = 0;
    while (true) {
        var a: u32 = 0;
        const print3 = try std.fmt.bufPrint(&buf, "smode mode counter: {}\n\r", .{counter});
        console.write(print3);
        counter += 1;
        while (true) {
            a += 1;
            if (a == 100000000) break;
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

export fn other_hart() void {
    var hartid: u8 = 0;
    asm volatile (
        \\ 
        : [hartid] "={a0}" (hartid),
    );
    console.write("other hart\r\n");
    while (true) {
        console.write("other hart inner loop\r\n");
        console.writeByte('0' + hartid);
        var a: u32 = 0;
        while (true) {
            a += 1;
            if (a == 100000000) break;
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

fn interrupt_handler_raw() callconv(.Naked) void {
    asm volatile (
        \\ addi sp, sp, -256
        \\ sd zero,0(sp)
        \\ sd ra,8(sp)
        \\ sd t0, 16(sp)
        \\ sd gp,24(sp)
        \\ sd tp,32(sp)
        \\ sd t1,48(sp)
        \\ sd t2,56(sp)
        \\ sd s0,64(sp)
        \\ sd s1,72(sp)
        \\ sd a0,80(sp)
        \\ sd a1,88(sp)
        \\ sd a2,96(sp)
        \\ sd a3,104(sp)
        \\ sd a4,112(sp)
        \\ sd a5,120(sp)
        \\ sd a6,128(sp)
        \\ sd a7,136(sp)
        \\ sd s2,144(sp)
        \\ sd s3,152(sp)
        \\ sd s4,160(sp)
        \\ sd s5,168(sp)
        \\ sd s6,176(sp)
        \\ sd s7,184(sp)
        \\ sd s8,192(sp)
        \\ sd s9,200(sp)
        \\ sd s10,208(sp)
        \\ sd s11,216(sp)
        \\ sd t3,224(sp)
        \\ sd t4,232(sp)
        \\ sd t5,240(sp)
        \\ sd t6,248(sp)
        \\ call %[handler]
        \\ ld zero,0(sp)
        \\ ld ra,8(sp)
        \\ ld t0, 16(sp)
        \\ ld gp,24(sp)
        \\ ld tp,32(sp)
        \\ ld t1,48(sp)
        \\ ld t2,56(sp)
        \\ ld s0,64(sp)
        \\ ld s1,72(sp)
        \\ ld a0,80(sp)
        \\ ld a1,88(sp)
        \\ ld a2,96(sp)
        \\ ld a3,104(sp)
        \\ ld a4,112(sp)
        \\ ld a5,120(sp)
        \\ ld a6,128(sp)
        \\ ld a7,136(sp)
        \\ ld s2,144(sp)
        \\ ld s3,152(sp)
        \\ ld s4,160(sp)
        \\ ld s5,168(sp)
        \\ ld s6,176(sp)
        \\ ld s7,184(sp)
        \\ ld s8,192(sp)
        \\ ld s9,200(sp)
        \\ ld s10,208(sp)
        \\ ld s11,216(sp)
        \\ ld t3,224(sp)
        \\ ld t4,232(sp)
        \\ ld t5,240(sp)
        \\ ld t6,248(sp)
        \\ addi sp, sp, 256
        \\ sret
        :
        : [handler] "i" (&interrupt_handler),
    );
}

const err_str = "error";
var intGlobal: u32 = 0;
var ibuf: [1000]u8 = undefined;
fn interrupt_handler() void {
    intGlobal += 1;
    var print = std.fmt.bufPrint(&ibuf, "Interrupt: {}\n\r", .{intGlobal}) catch {
        debug.hang();
        return;
    };
    console.write(print);
    const timer: u64 = time.read();

    //const sstatus = interrupt.sstatus.read();
    //_ = sstatus;
    var sip = interrupt.sip.read();
    const scause = interrupt.scause.read();
    if (scause.interrupt == 0) {}

    print = std.fmt.bufPrint(&ibuf, "Interrupt, scause: {}\n\r", .{scause}) catch {
        debug.hang();
        return;
    };
    console.write(print);
    const new_value = timer + 10000000;

    sip.ssip = 0;
    sip.write();
    var sepc: u64 = 0;
    asm volatile (
        \\ csrr %[sepc], sepc
        : [sepc] "=r" (sepc),
    );
    sepc += 4;
    asm volatile (
        \\ csrw sepc, %[sepc]
        : [sepc] "=r" (sepc),
    );

    sbi.sbi_set_timer(new_value) catch {
        debug.hang();
        return;
    };

    print = std.fmt.bufPrint(&ibuf, "Interrupt timer set: {}\n\r", .{new_value}) catch unreachable;
    console.write(print);
    return;
}
