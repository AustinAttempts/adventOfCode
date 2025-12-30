const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard Configuration Options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // create module
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const aoc2025 = b.dependency("AOC2025", .{
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("AOC2025", aoc2025.module("AOC2025"));

    //create executable
    const exe = b.addExecutable(.{
        .name = "adventOfCode",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
