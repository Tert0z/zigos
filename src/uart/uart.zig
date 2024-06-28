pub const Console = struct {
    tx: *u8,
    rx: *u8,
    lcr: *packed struct {
        data_length: u2,
        stop_bits: u1,
        parity_enable: u1,
        even_parity: u1,
        stick_parity: u1,
        set_break: u1,
        dlab: u1,
    },
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
    ier: *packed struct {
        enable_data_available_interrupt: u1,
        enable_transmitter_empty_interrupt: u1,
        enable_receiver_line_status_interrupt: u1,
        enable_modem_status_interrupt: u1,
    },
    dlh: *packed struct {
        dlh: u8,
    },
    mcr: *packed struct {
        dtr: u1,
        rts: u1,
        out1: u1,
        out2: u1,
        loop: u1,
    },
    fcr: *packed struct {
        enable_fifo: u1,
        clear_rcv_fifo: u1,
        clear_xmit_fifo: u1,
        dma_mode: u1,
    },

    const lcr_offset = 0x0C;
    const lsr_offset = 0x14;

    const baud_rate = 1_500_000;
    const uart_clock = 25000000;

    const divisor = uart_clock / (16 * baud_rate);

    pub fn init(base_addres: u64) Console {
        const c: Console = .{
            .tx = @ptrFromInt(base_addres + 0x0),
            .rx = @ptrFromInt(base_addres + 0x0),
            .lcr = @ptrFromInt(base_addres + lcr_offset),
            .lsr = @ptrFromInt(base_addres + lsr_offset),
            .dlh = @ptrFromInt(base_addres + 0x04),
            .ier = @ptrFromInt(base_addres + 0x04),
            .mcr = @ptrFromInt(base_addres + 0x10),
            .fcr = @ptrFromInt(base_addres + 0x08),
        };
        c.lcr.*.data_length = 0x3;
        c.lcr.*.dlab = 1;
        c.tx.* = divisor & 0xff;
        c.dlh.*.dlh = (divisor >> 8) & 0xff;
        c.lcr.*.dlab = 0;
        c.ier.* = .{
            .enable_data_available_interrupt = 0,
            .enable_transmitter_empty_interrupt = 0,
            .enable_receiver_line_status_interrupt = 0,
            .enable_modem_status_interrupt = 0,
        };
        c.mcr.*.rts = 1;
        c.fcr.* = .{
            .enable_fifo = 1,
            .clear_rcv_fifo = 1,
            .clear_xmit_fifo = 1,
            .dma_mode = 0,
        };
        c.lcr.*.data_length = 0x3;

        return c;
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
