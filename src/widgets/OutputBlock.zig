const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

text: []const u8,
min_width: u16 = 20,
min_height: u16 = 3,

const OutputBlock = @This();

pub fn widget(self: *const OutputBlock) vxfw.Widget {
    return .{
        .userdata = @constCast(self),
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *const OutputBlock = @ptrCast(@alignCast(ptr));

    const content_text: vxfw.Text = .{
        .text = self.text,
        .style = .{},
    };

    const text_surface = try content_text.draw(ctx);

    // Center the text in the block
    const width = @max(self.min_width, text_surface.size.width + 4);
    const height = @max(self.min_height, text_surface.size.height + 2);

    const text_col = (width - text_surface.size.width) / 2;
    const text_row = (height - text_surface.size.height) / 2;

    const children = try ctx.arena.alloc(vxfw.SubSurface, 1);
    children[0] = .{
        .origin = .{ .row = text_row, .col = text_col },
        .surface = text_surface,
    };

    return .{
        .size = .{ .width = width, .height = height },
        .widget = self.widget(),
        .buffer = &.{},
        .children = children,
    };
}
