pub fn read() u64 {
    var val: u64 = undefined;
    asm volatile (
        \\ csrr %[val], time
        : [val] "=r" (val),
    );
    return val;
}
