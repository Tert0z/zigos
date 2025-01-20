pub const SpinLock = struct {
    value: u64 = 0,

    pub fn lock(self: *SpinLock) void {
        const vptr = &self.value;
        asm volatile (
            \\spin_lock:
            \\ ldaxr x0, [%[val]]
            \\ cbz x0, store
            \\ wfe
            \\ b spin_lock
            \\store:
            \\ mov x0, #1
            \\ stlxr w1, x0, [%[val]]
            \\ cbnz w1, spin_lock
            :
            : [val] "r" (vptr),
        );
    }

    pub fn unlock(self: *SpinLock) void {
        const vptr = &self.value;
        asm volatile (
            \\ mov x0, #0
            \\ stlr x0, [%[val]]
            // TODO: Remove this when MMU is enabled
            \\ sev
            :
            : [val] "r" (vptr),
        );
    }
};
