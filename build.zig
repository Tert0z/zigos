const std = @import("std");
const Builder = @import("std").Build;
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;
const Feature = @import("std").Target.Cpu.Feature;

pub fn build(b: *Builder) void {
    const optimize = b.standardOptimizeOption(.{});
    buildKernel(b, optimize);
    //buildLogger(b, optimize);
}

pub fn buildKernel(b: *Builder, optimize: std.builtin.OptimizeMode) void {
    const targetQuery = Target.Query{
        .cpu_arch = Target.Cpu.Arch.aarch64,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_model = .{ .explicit = &Target.aarch64.cpu.cortex_a53 },
        .cpu_features_add = Target.aarch64.featureSet(&[_]Target.aarch64.Feature{.strict_align}),
    };

    const target = b.resolveTargetQuery(targetQuery);

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("src/bootstrap.zig"),
        .target = target,
        .optimize = optimize,
        .code_model = .large,
        .strip = false,
        .unwind_tables = true,
        .omit_frame_pointer = false,
    });

    kernel.setLinkerScriptPath(b.path("build/kernel.ld"));
    kernel.addAssemblyFile(b.path("src/interrupts/vector_table_jumps.S"));
    kernel.addAssemblyFile(b.path("src/smp/park.S"));
    b.installArtifact(kernel);

    const asm_module = b.addModule("asm_helpers", .{
        .root_source_file = b.path("src/asm/asm.zig"),
    });

    kernel.root_module.addImport("asm_helpers", asm_module);

    b.getInstallStep().dependOn(&kernel.step);
}
