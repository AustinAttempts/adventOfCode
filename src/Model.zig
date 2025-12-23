const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const ContentBox = @import("widgets/ContentBox.zig");

const Model = @This();

border: vxfw.Border,

pub fn widget(self: *Model) vxfw.Widget {
    return .{
        .userdata = self,
        .eventHandler = typeErasedEventHandler,
        .drawFn = typeErasedDrawFn,
    };
}

fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
    const self: *Model = @ptrCast(@alignCast(ptr));
    _ = self;
    switch (event) {
        .key_press => |key| {
            if (key.matches('c', .{ .ctrl = true }) or key.matches('q', .{})) {
                ctx.quit = true;
                return;
            }
        },
        else => {},
    }
}

fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
    const self: *Model = @ptrCast(@alignCast(ptr));
    const max_size = ctx.max.size();

    const bordered_surface = try self.border.draw(ctx);

    const box_col = if (max_size.width > bordered_surface.size.width)
        (max_size.width - bordered_surface.size.width) / 2
    else
        0;
    const box_row = if (max_size.height > bordered_surface.size.height)
        (max_size.height - bordered_surface.size.height) / 2
    else
        0;

    const children = try ctx.arena.alloc(vxfw.SubSurface, 1);
    children[0] = .{
        .origin = .{ .row = box_row, .col = box_col },
        .surface = bordered_surface,
    };

    return .{
        .size = max_size,
        .widget = self.widget(),
        .buffer = &.{},
        .children = children,
    };
}
