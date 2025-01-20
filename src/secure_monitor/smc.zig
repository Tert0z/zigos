pub fn call(function: u64) i64 {
    var ret: i64 = undefined;
    asm volatile (
        \\ mov x0, %[function]
        \\ smc 0x00
        \\ mov %[ret], x0
        : [ret] "=r" (ret),
        : [function] "r" (function),
    );
    return ret;
}

//TODO: refactor to use a variadic function
pub fn call3(function: u64, arg1: u64, arg2: u64, arg3: u64) i64 {
    var ret: i64 = undefined;
    asm volatile (
        \\ mov x0, %[function]
        \\ mov x1, %[arg1]
        \\ mov x2, %[arg2]
        \\ mov x3, %[arg3]
        \\ smc 0x00
        \\ mov %[ret], x0
        : [ret] "=r" (ret),
        : [function] "r" (function),
          [arg1] "r" (arg1),
          [arg2] "r" (arg2),
          [arg3] "r" (arg3),
    );
    return ret;
}
