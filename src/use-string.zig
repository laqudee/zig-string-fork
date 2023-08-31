const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const print = std.debug.print;
const assert = std.debug.assert;
const eql = std.mem.eql;

const zig_string = @import("main.zig");
const String = zig_string.String;

pub fn main() !void {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var myString = String.init(arena.allocator());
    defer myString.deinit();

    try myString.concat("🔥 Hello!");
    var str = myString.pop();
    print("{?s} \n", .{str});
    try myString.concat(", World 🔥");
    print("{?s} \n", .{myString.str()});
    print("capacity: {}, size: {} \n", .{ myString.capacity(), myString.size });

    var cmpResult: bool = myString.cmp("Hello, World!");
    print("{} \n", .{@intFromBool(cmpResult)});
    print("{} \n", .{cmpResult});

    var stringOne: ?usize = myString.find("🔥");
    print("{?} \n", .{stringOne});

    var myStringClone: String = try myString.clone();
    defer myStringClone.deinit();
    var res: bool = myStringClone.cmp(myString.str());
    print("{} \n", .{res});

    myString.reverse();
    print("{?s} \n", .{myString.str()});
    myString.reverse();

    assert(!myString.isEmpty());

    var myStr = String.init(arena.allocator());
    defer myStr.deinit();
    try myStr.concat("💯Hello💯");
    try myStr.repeat(2);
    print("{?s} \n", .{myStr.str()});

    const split_0: []const u8 = myStr.split("💯", 0).?;
    print("{?s} \n", .{split_0});

    assert(eql(u8, myStr.split("💯", 1).?, "Hello"));

    var subStr: String = try myStr.substr(0, 7);
    print("{?s} \n", .{subStr.str()});

    myStr.clear();
    assert(myStr.len() == 0);
    assert(myStr.size == 0);

    const writer = myStr.writer();
    const length: usize = try writer.write("This is a Use!");
    print("{?} \n", .{length});

    const mySlice = try myStr.toOwned();
    assert(eql(u8, mySlice.?, "This is a Use!"));
    arena.allocator().free(mySlice.?);

    var i: usize = 0;
    var iter = myStr.iterator();
    while (iter.next()) |ch| {
        if (i == 0) {
            assert(eql(u8, "T", ch));
        }
        i += 1;
    }
    assert(i == myStr.len());

    try init_with_contents();
}

fn init_with_contents() !void {
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit();

    var initial_contents = "String with initial contents";

    var myStr = try String.init_with_contents(arena.allocator(), initial_contents);
    print("{?s}", .{myStr.str()});
}
