const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

title: []const u8,
year_value: []const u8,
day_value: []const u8,
part1_output: []const u8,
part2_output: []const u8,
runtime_output: []const u8,

const ContentBox = @This();
const InputField = @import("InputField.zig");
const OutputBlock = @import("OutputBlock.zig");

pub fn widget(self: *const ContentBox) vxfw.Widget {
    return .{
        .userdata = @constCast(self),
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *const ContentBox = @ptrCast(@alignCast(ptr));

    // Title
    const title_text: vxfw.Text = .{
        .text = self.title,
        .style = .{ .bold = true },
    };
    const title_surface = try title_text.draw(ctx);

    // Horizontal line after title
    const line1_text: vxfw.Text = .{ .text = "─────────────────────────────────────────────────────────────" };
    const line1_surface = try line1_text.draw(ctx);

    // Input fields
    const year_field = InputField{
        .label = "Year:",
        .value = self.year_value,
    };
    const day_field = InputField{
        .label = "Day:",
        .value = self.day_value,
    };

    const year_surface = try year_field.widget().draw(ctx);
    const day_surface = try day_field.widget().draw(ctx);

    // Second horizontal line
    const line2_surface = try line1_text.draw(ctx);

    // Part 1
    const part1_label: vxfw.Text = .{ .text = "Part 1:" };
    const part1_label_surface = try part1_label.draw(ctx);

    const part1_block = OutputBlock{
        .text = self.part1_output,
        .min_width = 40,
        .min_height = 3,
    };
    const part1_border: vxfw.Border = .{ .child = part1_block.widget() };
    const part1_surface = try part1_border.draw(ctx);

    // Third horizontal line
    const line3_surface = try line1_text.draw(ctx);

    // Part 2
    const part2_label: vxfw.Text = .{ .text = "Part 2:" };
    const part2_label_surface = try part2_label.draw(ctx);

    const part2_block = OutputBlock{
        .text = self.part2_output,
        .min_width = 40,
        .min_height = 3,
    };
    const part2_border: vxfw.Border = .{ .child = part2_block.widget() };
    const part2_surface = try part2_border.draw(ctx);

    // Fourth horizontal line
    const line4_surface = try line1_text.draw(ctx);

    // Runtime (right-aligned)
    const runtime_label: vxfw.Text = .{ .text = "Runtime:" };
    const runtime_label_surface = try runtime_label.draw(ctx);

    const runtime_block = OutputBlock{
        .text = self.runtime_output,
        .min_width = 15,
        .min_height = 3,
    };
    const runtime_border: vxfw.Border = .{ .child = runtime_block.widget() };
    const runtime_surface = try runtime_border.draw(ctx);

    // Calculate layout
    const content_width: u16 = 60;
    var current_row: u16 = 0;

    var children_list: std.ArrayList(vxfw.SubSurface) = .empty;

    // Title (centered)
    const title_col = (content_width - title_surface.size.width) / 2;
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = title_col },
        .surface = title_surface,
    });
    current_row += title_surface.size.height + 1;

    // Line 1
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 0 },
        .surface = line1_surface,
    });
    current_row += 2;

    // Year and Day fields on same row
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 2 },
        .surface = year_surface,
    });
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 30 },
        .surface = day_surface,
    });
    current_row += year_surface.size.height + 2;

    // Line 2
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 0 },
        .surface = line2_surface,
    });
    current_row += 2;

    // Part 1
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 0 },
        .surface = part1_label_surface,
    });
    current_row += part1_label_surface.size.height + 1;
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 10 },
        .surface = part1_surface,
    });
    current_row += part1_surface.size.height + 2;

    // Line 3
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 0 },
        .surface = line3_surface,
    });
    current_row += 2;

    // Part 2
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 0 },
        .surface = part2_label_surface,
    });
    current_row += part2_label_surface.size.height + 1;
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 10 },
        .surface = part2_surface,
    });
    current_row += part2_surface.size.height + 2;

    // Line 4
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = 0 },
        .surface = line4_surface,
    });
    current_row += 2;

    // Runtime (right-aligned)
    const runtime_col = content_width - runtime_label_surface.size.width - runtime_surface.size.width - 2;
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = runtime_col },
        .surface = runtime_label_surface,
    });
    try children_list.append(ctx.arena, .{
        .origin = .{ .row = current_row, .col = runtime_col + runtime_label_surface.size.width + 1 },
        .surface = runtime_surface,
    });
    current_row += runtime_surface.size.height;

    return .{
        .size = .{ .width = content_width, .height = current_row },
        .widget = self.widget(),
        .buffer = &.{},
        .children = try children_list.toOwnedSlice(
            ctx.arena,
        ),
    };
}
