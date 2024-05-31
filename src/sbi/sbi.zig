pub const SbiError = error{
    Failed,
    NotSupported,
    InvalidParam,
    Denied,
    InvalidAddress,
    AlreadyAvailable,
    AlreadyStarted,
    AlreadyStopped,
};

pub const SbiErrorEnum = enum(i32) {
    OK = 0,
    Failed = -1,
    NotSupported = -2,
    InvalidParam = -3,
    Denied = -4,
    InvalidAddress = -5,
    AlreadyAvailable = -6,
    AlreadyStarted = -7,
    AlreadyStopped = -8,
};

pub const SbiExtId = enum(u32) {
    Base = 0x10,
    Time = 0x54494D45,
    Ipi = 0x73504949,
    RFence = 0x52464E43,
    Hsm = 0x48534D,
};

pub fn sbi_set_timer(stime: u64) SbiError!void {
    return sbi_call(SbiExtId.Time, 0, stime, 0);
}

pub const HSM = struct {
    pub fn start_hart(hartid: u32, start_addr: u64) SbiError!void {
        return sbi_call(SbiExtId.Hsm, 0, hartid, start_addr);
    }
};

fn sbi_call(eid: SbiExtId, fid: u32, arg: u64, arg2: u64) SbiError!void {
    var err: u32 = 0;
    asm volatile (
        \\ ecall
        : [_] "={a0}" (err),
        : [_] "{a0}" (arg),
          [_] "{a1}" (arg2),
          [_] "{a7}" (eid),
          [_] "{a6}" (fid),
    );
    const sbiError: SbiErrorEnum = @enumFromInt(err);
    return switch (sbiError) {
        SbiErrorEnum.OK => {},
        SbiErrorEnum.Failed => SbiError.Failed,
        SbiErrorEnum.NotSupported => SbiError.NotSupported,
        SbiErrorEnum.InvalidParam => SbiError.InvalidParam,
        SbiErrorEnum.Denied => SbiError.Denied,
        SbiErrorEnum.InvalidAddress => SbiError.InvalidAddress,
        SbiErrorEnum.AlreadyAvailable => SbiError.AlreadyAvailable,
        SbiErrorEnum.AlreadyStarted => SbiError.AlreadyStarted,
        SbiErrorEnum.AlreadyStopped => SbiError.AlreadyStopped,
    };
}
