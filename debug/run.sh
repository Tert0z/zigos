ssh -L 31313:localhost:3333 -T adam@192.168.0.245 "openocd -f debug.conf"  > /dev/null 2>&1 &
ssh_pid=$!

sleep 2
riscv64-elf-gdb -x ./debug/debug.gdb

kill $ssh_pid
ssh adam@192.168.0.245 "pkill -9 openocd"
