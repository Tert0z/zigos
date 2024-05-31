pub const sstatus = packed struct {
    reserved0: u1,
    sie: u1,
    reserved4_2: u3,
    spie: u1,
    reserved6_7: u2,
    spp: u1,
    reserved9_63: u55,

    pub fn read() sstatus {
        var val: sstatus = undefined;
        asm volatile (
            \\ csrr %[val], sstatus
            : [val] "=r" (val),
        );
        return val;
    }

    pub fn write(self: sstatus) void {
        asm volatile (
            \\ csrw sstatus, %[val]
            :
            : [val] "r" (self),
        );
    }
};

pub const scause = packed struct {
    interrupt: u63,
    cause: u1,

    pub fn read() scause {
        var val: scause = undefined;
        asm volatile (
            \\ csrr %[val], scause
            : [val] "=r" (val),
        );
        return val;
    }

    pub fn write(self: scause) void {
        asm volatile (
            \\ csrw scause, %[val]
            :
            : [val] "r" (self),
        );
    }
};

pub const sie = packed struct {
    reserved0: u1,
    ssie: u1,
    reserved2_4: u3,
    stie: u1,
    reserved6_8: u3,
    seie: u1,
    reserved10_63: u54,

    pub fn read() sie {
        var val: sie = undefined;
        asm volatile (
            \\ csrr %[val], sie
            : [val] "=r" (val),
        );
        return val;
    }

    pub fn write(self: sie) void {
        asm volatile (
            \\ csrw sie, %[val]
            :
            : [val] "r" (self),
        );
    }
};

pub const sip = packed struct {
    reserved0: u1,
    ssip: u1,
    reserved2_4: u3,
    stip: u1,
    reserved6_8: u3,
    seip: u1,
    reserved10_63: u54,

    pub fn read() sip {
        var val: sip = undefined;
        asm volatile (
            \\ csrr %[val], sip
            : [val] "=r" (val),
        );
        return val;
    }

    pub fn write(self: sip) void {
        asm volatile (
            \\ csrw sip, %[val]
            :
            : [val] "r" (self),
        );
    }
};
