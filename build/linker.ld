ENTRY(_start)

SECTIONS {
    . = 0x80000000;

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
        . += 0x100001;
        . = ALIGN(16);
        PROVIDE( _sp = . );
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _h2_sp = . );
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _h3_sp = . );
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _h4_sp = . );
        . += 0x100000;
        . = ALIGN(16);
        PROVIDE( _isp = . );
    }
}
