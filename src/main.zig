const uart: u64 = 0x10000000;
const uart_write: *u8 = @ptrFromInt(uart);

pub fn kmain() noreturn {
    uart_write.* = 'H';
    uart_write.* = 'e';
    uart_write.* = 'l';
    uart_write.* = 'l';
    uart_write.* = 'o';
    //uart_write.* = ' ';
    //uart_write.* = 'w';
    //uart_write.* = 'o';
    //uart_write.* = 'r';
    //uart_write.* = 'l';
    //uart_write.* = 'd';
    //uart_write.* = '!';
    unreachable();
}
