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
        .cpu_model = .{ .explicit = &Target.riscv.cpu.baseline_rv64 },
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
    kernel.addAssemblyFile(.{ .path = "src/interrupts/handler.S" });

    var kernel_artifact = b.addInstallArtifact(kernel, .{});
    b.getInstallStep().dependOn(&kernel_artifact.step);
}
