const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const Model = struct {
    border: vxfw.Border,

    pub fn widget(self: *Model) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = Model.typeErasedEventHandler,
            .drawFn = Model.typeErasedDrawfn,
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

    fn typeErasedDrawfn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
        const self: *Model = @ptrCast(@alignCast(ptr));
        const max_size = ctx.max.size();

        // Draw the bordered content
        const bordered_surface = try self.border.draw(ctx);

        // Calculate centered position
        const box_col = if (max_size.width > bordered_surface.size.width)
            (max_size.width - bordered_surface.size.width) / 2
        else
            0;
        const box_row = if (max_size.height > bordered_surface.size.height)
            (max_size.height - bordered_surface.size.height) / 2
        else
            0;

        // Position the bordered box in the center
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
};

const ContentWidget = struct {
    pub fn widget(self: *const ContentWidget) vxfw.Widget {
        return .{
            .userdata = @constCast(self),
            .drawFn = typeErasedDrawFn,
        };
    }

    fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
        const self: *const ContentWidget = @ptrCast(@alignCast(ptr));

        // Create title with bold style
        const title_text: vxfw.Text = .{
            .text = "Title Block",
            .style = .{ .bold = true },
        };

        // Create content text
        const content_text: vxfw.Text = .{
            .text = "Hello World! This is a context field",
        };

        // Draw title and content
        const title_surface = try title_text.draw(ctx);
        const content_surface = try content_text.draw(ctx);

        // Create children with title and content
        const children = try ctx.arena.alloc(vxfw.SubSurface, 2);
        children[0] = .{
            .origin = .{ .row = 0, .col = 0 },
            .surface = title_surface,
        };
        children[1] = .{
            .origin = .{ .row = 2, .col = 0 },
            .surface = content_surface,
        };

        // Calculate size needed for content
        const width = @max(title_surface.size.width, content_surface.size.width);
        const height = 3; // title + empty line + content

        return .{
            .size = .{ .width = width, .height = height },
            .widget = self.widget(),
            .buffer = &.{},
            .children = children,
        };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    const model = try allocator.create(Model);
    defer allocator.destroy(model);

    const content = try allocator.create(ContentWidget);
    defer allocator.destroy(content);
    content.* = .{};

    model.* = .{
        .border = .{
            .child = content.widget(),
        },
    };

    try app.run(model.widget(), .{});
}
