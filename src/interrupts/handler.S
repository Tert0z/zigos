
.global interrupt_handler_asm
interrupt_handler_asm:
    la sp, _h2_sp
    call other_hart
