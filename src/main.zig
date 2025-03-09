const uart = @import("uart/uart.zig");
const std = @import("std");
const secure_monitor = @import("secure_monitor/smc.zig");
const smp = @import("smp/registers.zig");
const clock = @import("clock/clock.zig");
const registers_sctlr = @import("registers/sctlr.zig");
const asm_helpers = @import("asm_helpers");
const sync = @import("sync/spin_lock.zig");

var buf: [1000]u8 = undefined;
var console: uart.Console = uart.Console.init(0x09000000);
var testValue: u64 = 0;

pub fn kmain() noreturn {
    testValue = 1;

    run() catch unreachable;

    while (true) {}
    unreachable;
}

extern const vector_table_jumps: u32;

const CSRRegister = packed struct {};
var lock: sync.SpinLock = sync.SpinLock{ .value = 0 };

export fn secondary_cpu_init() void {
    //console.write("Secondary CPU\n\r");
    const mpidr_el1 = smp.MPIDR.init();

    //asm_helpers.write_system_reg("ttbr0_el1", 0x7fee0000);
    //asm_helpers.write_system_reg("VBAR_EL1", @intFromPtr(&vector_table_jumps));

    //var sctlr = registers_sctlr.SCTLR.init();
    //sctlr.data_cache_enable = 1;
    //sctlr.instruction_cache_enable = 1;
    //sctlr.mmu_enable = 1;
    //sctlr.alignment_check = 0;
    //sctlr.stack_pointer_alignment_check = 0;
    //sctlr.write();
    var buf2: [100]u8 = undefined;
    var c_local: uart.Console = uart.Console.init(0x3089_0000);

    //lock.lock();
    const p2 = std.fmt.bufPrint(&buf2, "Secondary SCTLR: {}\n\r", .{mpidr_el1}) catch unreachable;
    c_local.write(p2);
    //lock.unlock();

    var c: u64 = 0;

    while (true) {
        c += 1;
        //const timer = asm_helpers.read_system_reg("CNTPCT_EL0");
        //sleep();
        //const timer2 = asm_helpers.read_system_reg("CNTPCT_EL0");
        //const diff = timer2 - timer;
        const val = asm_helpers.read_system_reg("CurrentEL");
        const p3 = std.fmt.bufPrint(&buf2, "Read: {} {} {} {}\n\r", .{ mpidr_el1.Aff0, 0, c, val }) catch unreachable;
        //lock.lock();
        c_local.write(p3);
        //lock.unlock();
    }
}

export fn irq() void {
    console.write("IRQ!\n\r");

    const currentEL: u64 = 1; //asm_helpers.read_system_reg("CurrentEL");

    const elr_el1: u64 = 2; //asm_helpers.read_system_reg("elr_el1");
    const esr_el1: u64 = 3; //asm_helpers.read_system_reg("esr_el1");

    const print = std.fmt.bufPrint(&buf,
        \\  CurrentEL: {x}
        \\  ELR_EL1: {x}
        \\  ESR_EL1: {x}
    , .{ currentEL, elr_el1, esr_el1 }) catch unreachable;
    console.write(print);
    while (true) {
        sleep();
    }
}

extern const park_thread: u64;
extern const park_thread2: u64;
extern const park_thread3: u64;

pub fn run() !void {
    console.write("Hello, world!\n\r");

    var sp: u64 = undefined;
    asm volatile (
        \\ mov %[sp], sp
        : [sp] "=r" (sp),
    );

    const val = asm_helpers.read_system_reg("CurrentEL");
    const mpidr_el1 = smp.MPIDR.init();
    const ttbr0_el2 = asm_helpers.read_system_reg("ttbr0_el1");
    const sctlr = registers_sctlr.SCTLR.init();
    const clk = clock.ACPUCTRL.init();

    const smc_version = secure_monitor.call(0x80000000);

    const print = std.fmt.bufPrint(&buf,
        \\ CurrentEL: {x}, SP: {x}, SMC: {x},
        \\ MPIDR_EL1: {}, 
        \\ TTBRO_EL2: {x}
        \\ CLK: {}
        \\ SCTLR: {}
    , .{ val, sp, smc_version, mpidr_el1, ttbr0_el2, clk, sctlr }) catch unreachable;
    console.write(print);
    //asm volatile ("wfi");

    var c: u64 = 0;
    while (true) {
        c += 1;
        const timer = asm_helpers.read_system_reg("CNTPCT_EL0");
        sleep();

        const timer2 = asm_helpers.read_system_reg("CNTPCT_EL0");
        const diff = timer2 - timer;
        const p1 = std.fmt.bufPrint(&buf, "Read: {} {} {}\n\r", .{ mpidr_el1.Aff0, diff, c }) catch unreachable;
        //lock.lock();
        console.write(p1);
        //lock.unlock();
        testValue += 1;
        if (c == 1) {
            const park_thread_addr2 = @intFromPtr(&park_thread2);
            var ret = secure_monitor.call3(0xC400_0003, 1, park_thread_addr2, 0);
            ret = ret;
            const p22 = std.fmt.bufPrint(&buf, "SMC: {} ADDR: {x}\n\r", .{ ret, park_thread_addr2 }) catch unreachable;
            console.write(p22);

            //const park_thread_addr = @intFromPtr(&park_thread);
            //ret = secure_monitor.call3(0xC400_0003, 1, park_thread_addr, 0);
            //const p2 = std.fmt.bufPrint(&buf, "SMC: {} ADDR: {x}\n\r", .{ ret, park_thread_addr }) catch unreachable;
            //console.write(p2);

            //const park_thread_addr3 = @intFromPtr(&park_thread3);
            //ret = secure_monitor.call3(0xC400_0003, 3, park_thread_addr3, 0);
            //const p23 = std.fmt.bufPrint(&buf, "SMC: {} ADDR: {x}\n\r", .{ ret, park_thread_addr3 }) catch unreachable;
            //console.write(p23);
        }
    }
    return;

    //secondary_cpu_init();
}

noinline fn sleep() void {
    for (0..10000000) |_| {
        asm volatile ("nop");
    }
}
