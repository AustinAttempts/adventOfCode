const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

label: []const u8,
value: []const u8,
label_style: vaxis.Style = .{},
value_style: vaxis.Style = .{},

const InputField = @This();

pub fn widget(self: *const InputField) vxfw.Widget {
    return .{
        .userdata = @constCast(self),
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *const InputField = @ptrCast(@alignCast(ptr));

    // Create label text
    const label_text: vxfw.Text = .{
        .text = self.label,
        .style = self.label_style,
    };

    // Create value in a border
    const value_text: vxfw.Text = .{
        .text = self.value,
        .style = self.value_style,
    };

    _ = try value_text.draw(ctx);

    // Add border around value
    const value_border: vxfw.Border = .{
        .child = value_text.widget(),
    };

    const bordered_value = try value_border.draw(ctx);

    // Draw label
    const label_surface = try label_text.draw(ctx);

    // Position label and bordered value side by side
    const children = try ctx.arena.alloc(vxfw.SubSurface, 2);
    children[0] = .{
        .origin = .{ .row = 0, .col = 0 },
        .surface = label_surface,
    };
    children[1] = .{
        .origin = .{ .row = 0, .col = label_surface.size.width + 1 },
        .surface = bordered_value,
    };

    const width = label_surface.size.width + 1 + bordered_value.size.width;
    const height = @max(label_surface.size.height, bordered_value.size.height);

    return .{
        .size = .{ .width = width, .height = height },
        .widget = self.widget(),
        .buffer = &.{},
        .children = children,
    };
}
