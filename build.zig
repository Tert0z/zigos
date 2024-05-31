const std = @import("std");
const Builder = @import("std").Build;
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;
const Feature = @import("std").Target.Cpu.Feature;

pub fn build(b: *Builder) void {
    const targetQuery = Target.Query{
        .cpu_arch = Target.Cpu.Arch.riscv64,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_model = .{ .explicit = &Target.riscv.cpu.sifive_u74 },
    };

    const target = b.resolveTargetQuery(targetQuery);

    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_source_file = .{ .path = "src/bootstrap.zig" },
        .target = target,
        .optimize = optimize,
        .code_model = .medium,
    });

    kernel.setLinkerScriptPath(.{ .path = "build/linker.ld" });
    var kernel_artifact = b.addInstallArtifact(kernel, .{});
    b.getInstallStep().dependOn(&kernel_artifact.step);

    //const iso_dir = b.fmt("{s}/iso_root", .{b.cache_root.path.?});
    //const kernel_path = b.exe_dir;
    //const iso_path = b.fmt("{s}/disk.iso", .{b.exe_dir});

    //const iso_cmd_str = &[_][]const u8{
    //"/bin/sh", "-c", std.mem.concat(b.allocator, u8, &[_][]const u8{
    //"mkdir -p ", iso_dir, "/boot/grub/", " && ",
    //"cp ", kernel_path, "/", kernel.name, " ", iso_dir, " && ", //
    //"cp build/grub.cfg ", iso_dir,  "/boot/grub/", " && ", //
    //"grub-mkrescue -o ",  iso_path, " ",           iso_dir,
    //}) catch unreachable,
    //};

    //const iso_cmd = b.addSystemCommand(iso_cmd_str);
    //iso_cmd.step.dependOn(&kernel_artifact.step);

    //const iso_step = b.step("iso", "Build an ISO image");
    //iso_step.dependOn(&iso_cmd.step);
    //b.default_step.dependOn(iso_step);

    //const run_cmd_str = &[_][]const u8{
    //"qemu-system-riscv64",
    //"-cdrom", iso_path, //
    //"-m", "4G", //
    //"-machine",   "sifive_u", //
    //"-no-reboot",
    //};

    //const run_cmd = b.addSystemCommand(run_cmd_str);
    //run_cmd.step.dependOn(b.getInstallStep());

    //const run_step = b.step("run", "Run the kernel");
    //run_step.dependOn(&run_cmd.step);

    //const debug_cmd_str = &[_][]const u8{
    //"qemu-system-riscv64",
    //"-cdrom", iso_path, //
    //"-m", "4G", //
    //"-machine",   "sifive_u", //
    //"-no-reboot",
    //"-s", "-S", //
    //};

    //const debug_cmd = b.addSystemCommand(debug_cmd_str);
    //debug_cmd.step.dependOn(b.getInstallStep());

    //const debug_step = b.step("debug", "Debug the kernel");
    //debug_step.dependOn(&debug_cmd.step);
}
