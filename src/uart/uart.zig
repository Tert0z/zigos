const std = @import("std");
pub const Console = struct {
    tx: *u8,
    rx: *u8,
    status: *packed struct {
        reserved: u13,
        trdy: u1,
    },

    const lsr_offset = 0x14;

    pub fn init(base_address: usize) Console {
        return .{
            .tx = @ptrFromInt(base_address + 0x0),
            .rx = @ptrFromInt(base_address + 0x40),
            .status = @ptrFromInt(base_address + 0x94),
        };
    }

    pub fn write(self: *Console, data: anytype) void {
        for (data) |v| {
            if (v == '\n') {
                self.writeByte('\r');
            }
            self.writeByte(v);
        }
    }

    pub fn writeByte(self: *Console, data: u8) void {
        //while (self.status.*.trdy == 0) {}
        self.tx.* = data;
    }
};
