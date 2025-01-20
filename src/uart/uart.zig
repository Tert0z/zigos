const std = @import("std");
pub const Console = struct {
    tx: *u8,
    rx: *u8,
    channel_sts: *packed struct {
        reserved: u3,
        tx_fifo_empty: u1,
    },

    const lsr_offset = 0x14;

    pub fn init(base_addres: usize) Console {
        return .{
            .tx = @ptrFromInt(base_addres + 0x30),
            .rx = @ptrFromInt(base_addres + 0x30),
            .channel_sts = @ptrFromInt(base_addres + 0x2c),
        };
    }

    pub fn write(self: *Console, data: anytype) void {
        const base_addres = 0xFF00_0000;
        self.tx = @ptrFromInt(base_addres + 0x30);
        self.channel_sts = @ptrFromInt(base_addres + 0x2c);

        for (data) |v| {
            if (v == '\n') {
                self.writeByte('\r');
            }
            self.writeByte(v);
        }
    }

    pub fn writeByte(self: *Console, data: u8) void {
        while (self.channel_sts.*.tx_fifo_empty == 0) {}
        self.tx.* = data;
    }
};
