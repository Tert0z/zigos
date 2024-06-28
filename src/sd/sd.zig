pub const Sd = struct {
    capabilities : *packed struct {
        timeoutClockFrequency : u6,
        reserved : u1,
        timeoutUnit : u1,
        baseClockFrequency : u8,
        maxBlockLength : u2,
    },

    pub fn init(base_addres: u64) Sd{
        return .{
            .capabilities = @ptrFromInt(base_addres + 0x040),
        };
    }

    //pub fn 
};
