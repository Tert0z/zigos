pub const Console = struct {
    tx: *u8,
    rx: *u8,
    lsr: *packed struct {
        data_ready: u1,
        overrun_error: u1,
        parity_error: u1,
        framing_error: u1,
        break_interrupt: u1,
        transmitter_holding_register_empty: u1,
        transmitter_empty: u1,
        error_in_rcv_fifo: u1,
    },

    const lsr_offset = 0x14;

    pub fn init(base_addres: u64) Console {
        return .{
            .tx = @ptrFromInt(base_addres + 0x0),
            .rx = @ptrFromInt(base_addres + 0x0),
            .lsr = @ptrFromInt(base_addres + lsr_offset),
        };
    }

    pub fn write(self: Console, data: anytype) void {
        for (data) |v| {
            self.writeByte(v);
        }
    }

    pub fn writeByte(self: Console, data: u8) void {
        while (self.lsr.*.transmitter_empty == 0) {}
        self.tx.* = data;
    }
};
