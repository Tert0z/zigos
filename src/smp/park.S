

.align 16
.global park_thread
park_thread:
  # TODO:  allocate dynamically
  ldr x1, =_sp1
  mov sp, x1
  mrs x1, sctlr_el1
  orr x1, x1, #0x1
  orr x1, x1, #0x4
  orr x1, x1, #0x1000
  msr sctlr_el1, x1
  mov x1, #0x7fee0000
  msr ttbr0_el1, x1
  bl secondary_cpu_init

.align 16
.global park_thread2
park_thread2:
  # TODO:  allocate dynamically
  ldr x1, =_sp2
  mov sp, x1
  bl secondary_cpu_init

.align 16
.global park_thread3
park_thread3:
  # TODO:  allocate dynamically
  ldr x1, =_sp3
  mov sp, x1
  bl secondary_cpu_init
