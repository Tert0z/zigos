ENTRY(_start)
 
SECTIONS {
    . = 0x80000000;

    .text : ALIGN(4K) {
        *(.text)
    }

    .stack : ALIGN(4K) {
        . += 0x1000;
        PROVIDE( _sp = . );
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
}
