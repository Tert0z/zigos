

.global vector_table_jumps
.p2align 11
vector_table_jumps:
    eret
.balign 0x200
    bl irq
    eret
