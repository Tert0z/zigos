ENTRY(_start_logger)

SECTIONS {
    . = 0x20000000;

    .text : ALIGN(4K) {
        *(.text)
    }

    .rodata : ALIGN(4K) {
        *(.rodata*)
    }
 
    .data : ALIGN(4K) {
        *(.data)
    }
 
    .bss : ALIGN(4K) {
        *(COMMON)
        *(.bss)
    }

    .stack  (NOLOAD): ALIGN(16) {
        . = 0x30000000;
        . +=0x00100000;
        . = ALIGN(16);
        PROVIDE( _sp = . );
    }
}
