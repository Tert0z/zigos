ENTRY(_start)

SECTIONS {
    . = 0x10000000;

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
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _sp1 = . );
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _sp2 = . );
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _sp3 = . );
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _sp = . );
    }
}
