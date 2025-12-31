const std = @import("std");
const AOC2024 = @import("AOC2024");
const AOC2025 = @import("AOC2025");

// ANSI color codes
const CYAN = "\x1b[36m";
const YELLOW = "\x1b[33m";
const RESET = "\x1b[0m";
const BOLD = "\x1b[1m";

pub fn main() !void {
    std.debug.print("\n\n", .{});
    std.debug.print("\t⭐️🎄 {s}Advent of Code 2024{s} 🎄⭐️\n", .{ BOLD, RESET });
    try AOC2024.printSolution();
    std.debug.print("\t⭐️🎄 {s}Advent of Code 2025{s} 🎄⭐️\n", .{ BOLD, RESET });
    try AOC2025.printSolution();
}
