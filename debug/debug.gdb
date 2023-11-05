file zig-out/bin/kernel
target extended-remote localhost:31313
restore zig-out/bin/kernel binary 0xa0000000
hb _start
tui enable 
layout split

