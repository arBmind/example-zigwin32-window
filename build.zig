const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = std.zig.CrossTarget{ .os_tag = .windows, .cpu_arch = .x86_64 };
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zigwin32-window",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const win32_module = b.dependency("win32", .{}).module("zigwin32");

    exe.addModule("zigwin32", win32_module);
    exe.subsystem = .Windows;

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
