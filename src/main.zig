const std = @import("std");
const expect = @import("std").testing.expect;

pub fn main() !void {
    std.debug.print("Empty main", .{});
}

pub const Font = struct {
    size: u8 = 14,
    cursive: bool = false,
    bold: bool = false,
};

pub const DialogText = struct {
    font: *const Font,
    text: []const u8,
};

pub const Dialog = struct {
    dialogs: [10]DialogText = [_]DialogText{undefined} ** 10,
    current_dialog: u8 = 0,
    number_of_dialogs: u8 = 0,

    const Self = @This();

    pub fn get(self: Self) *const DialogText {
        return &self.dialogs[self.current_dialog];
    }

    pub fn add(self: *Self, dialog: DialogText) void {
        self.dialogs[self.number_of_dialogs] = dialog;
        self.number_of_dialogs += 1;
    }

    pub fn next(self: *Self) void {
        self.current_dialog += 1;
    }
};

test "simple test" {
    const allocator = std.testing.allocator;
    const dialogs = try allocator.alloc(Dialog, 5);
    defer allocator.free(dialogs);

    try expect(dialogs.len == 5);
    try expect(@TypeOf(dialogs) == []Dialog);

    const big_font = Font{ .size = 18, .bold = true, .cursive = false };
    const normal_font = Font{};
    const fancy_font = Font{ .cursive = true };

    const dialog_one = DialogText{ .font = &normal_font, .text = "Some dialog for testing." };
    const dialog_two = DialogText{ .font = &big_font, .text = "Big font needs some shouting! RAWR!!!" };
    const dialog_three = DialogText{ .font = &fancy_font, .text = "Mmmmmmmmmmhm me lady~" };

    dialogs[0] = Dialog{};
    dialogs[0].add(dialog_one);
    dialogs[0].add(dialog_two);
    dialogs[0].add(dialog_three);

    const dialog = &dialogs[0];

    try expect(std.mem.eql(u8, dialog.get().text, "Some dialog for testing."));

    dialog.next();
    try expect(std.mem.eql(u8, dialog.get().text, "Big font needs some shouting! RAWR!!!"));
}
