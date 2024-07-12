const std = @import("std");
const Builder = @import("std").Build;
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;
const Feature = @import("std").Target.Cpu.Feature;

pub fn build(b: *Builder) void {
    const targetQuery = Target.Query{
        .cpu_arch = Target.Cpu.Arch.aarch64,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_model = .{ .explicit = &Target.aarch64.cpu.cortex_a53 },
    };

    const target = b.resolveTargetQuery(targetQuery);

    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_source_file = b.path("src/bootstrap.zig"),
        .target = target,
        .optimize = optimize,
        .code_model = .small,
    });

    kernel.setLinkerScriptPath(b.path("build/linker.ld"));
    //kernel.addAssemblyFile(b.path("src/interrupts/handler.S"));
    //var kernel_artifact = b.addInstallArtifact(kernel, .{});
    //b.getInstallStep().dependOn(&kernel_artifact.step);
    b.installArtifact(kernel);
}
