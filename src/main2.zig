const std = @import("std");
const Allocator = @import("std").mem.Allocator;
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

pub const DialogError = error{
    ListIsFull,
};

fn FixedSizeList(comptime T: type, comptime length: comptime_int) type {
    return struct {
        position: usize = 0,
        length: usize = length,
        items: []T,
        allocator: *const std.mem.Allocator,

        const Self = @This();

        fn init(allocator: *const Allocator) !FixedSizeList(T, length) {
            return .{
                .position = 0,
                .allocator = allocator,
                .items = try allocator.alloc(T, length),
            };
        }

        fn deinit(self: Self) void {
            self.allocator.free(self.items);
        }

        fn add(self: *Self, value: T) DialogError!void {
            if (self.position == self.items.len) {
                return DialogError.ListIsFull;
            }
            self.items[self.position] = value;
            self.position += 1;
        }

        fn get(self: Self, index: usize) *T {
            return &self.items[index];
        }
    };
}

pub const Book = struct {
    id: u16,
    dialogs: []DialogText,
    current_dialog: u8 = 0,

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
    var dialog = try FixedSizeList(DialogText, 3).init(&allocator);
    defer dialog.deinit();

    const big_font = Font{ .size = 18, .bold = true, .cursive = false };
    const normal_font = Font{};
    const fancy_font = Font{ .cursive = true };

    const dialog_text_one = DialogText{ .font = &normal_font, .text = "Some dialog for testing." };
    const dialog_text_two = DialogText{ .font = &big_font, .text = "Big font needs some shouting! RAWR!!!" };
    const dialog_text_three = DialogText{ .font = &fancy_font, .text = "Mmmmmmmmmmhm me lady~" };

    try dialog.add(dialog_text_one);
    try dialog.add(dialog_text_two);
    try dialog.add(dialog_text_three);

    try expect(dialog.items.len == 3);
    try expect(std.mem.eql(u8, dialog.get(1).*.text, "Big font needs some shouting! RAWR!!!"));
}

// What I need:
// Storing data
// Easy access to data
// ONE struct that uses a single pointer to the active dialog
