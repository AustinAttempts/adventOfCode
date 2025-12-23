const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Model = @import("Model.zig");
const ContentBox = @import("widgets/ContentBox.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    const model = try allocator.create(Model);
    defer allocator.destroy(model);

    const content_box = try allocator.create(ContentBox);
    defer allocator.destroy(content_box);

    content_box.* = .{
        .title = "Title Block",
        .year_value = "User Input",
        .day_value = "User Input",
        .part1_output = "Output Block",
        .part2_output = "Output Block",
        .runtime_output = "Output Block",
    };

    model.* = .{
        .border = .{ .child = content_box.widget() },
    };

    try app.run(model.widget(), .{});
}
