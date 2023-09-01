const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const assert = std.debug.assert;
const print = std.debug.print;
const eql = std.mem.eql;

const zig_string = @import("main.zig");
const String = zig_string.String;

test "Basic Usage" {
    // Use your favorite allocator
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // Create your String
    var myString = String.init(arena.allocator());
    defer myString.deinit();

    // Use functions provided
    try myString.concat("🔥 Hello!");
    _ = myString.pop();
    try myString.concat(", World 🔥");

    // Success!
    assert(myString.cmp("🔥 Hello, World 🔥"));
}

test "String Tests" {
    // Allocator for the String
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit();

    // This is how we create the String
    var myStr = String.init(arena.allocator());
    defer myStr.deinit();

    // allocate & capacity
    try myStr.allocate(16);
    assert(myStr.capacity() == 16);
    assert(myStr.size == 0);

    // truncate
    try myStr.truncate();
    assert(myStr.capacity() == myStr.size);
    assert(myStr.capacity() == 0);

    // concat
    try myStr.concat("A"); // size: 1
    print("{} \n", .{myStr.size}); // 1
    try myStr.concat("\u{5360}"); // size: 3
    print("{} \n", .{myStr.size}); // 4
    try myStr.concat("💯"); // size: 4
    print("{} \n", .{myStr.size}); // 8
    try myStr.concat("Hello🔥"); // size: 5 + 4
    print("{?s} \n", .{myStr.str()}); // A占💯Hello🔥

    assert(myStr.size == 17);

    // pop & length
    // len是，ASCII码与Unicode字符数的集合
    assert(myStr.len() == 9);
    assert(eql(u8, myStr.pop().?, "🔥"));
    assert(myStr.len() == 8);
    assert(eql(u8, myStr.pop().?, "o"));
    assert(myStr.len() == 7);

    // str & cmp
    assert(myStr.cmp("A\u{5360}💯Hell"));
    assert(myStr.cmp(myStr.str()));

    // charAt
    // 返回一个unicode字符
    assert(eql(u8, myStr.charAt(2).?, "💯"));
    assert(eql(u8, myStr.charAt(1).?, "\u{5360}"));
    assert(eql(u8, myStr.charAt(0).?, "A"));

    // insert
    // 插入一个unicode字符
    try myStr.insert("🔥", 1);
    assert(eql(u8, myStr.charAt(1).?, "🔥"));
    assert(myStr.cmp("A🔥\u{5360}💯Hell"));

    // find
    // 查找一个unicode字符
    assert(myStr.find("🔥").? == 1);
    assert(myStr.find("💯").? == 3);
    assert(myStr.find("Hell").? == 4);

    // remove & removeRange
    try myStr.removeRange(0, 3);
    assert(myStr.cmp("💯Hell"));
    try myStr.remove(myStr.len() - 1);
    assert(myStr.cmp("💯Hel"));

    // 白名单
    const whitelist = [_]u8{ ' ', '\t', '\n', '\r' };

    // trimStart
    try myStr.insert("      ", 0);
    print("{?s} \n", .{myStr.str()});
    myStr.trimStart(whitelist[0..]);
    assert(myStr.cmp("💯Hel"));

    // trimEnd
    _ = try myStr.concat("lo💯\n      ");
    myStr.trimEnd(whitelist[0..]);
    assert(myStr.cmp("💯Hello💯"));

    // clone
    // 返回一个新的String 类型
    var testStr = try myStr.clone();
    defer testStr.deinit();
    assert(testStr.cmp(myStr.str()));

    // reverse
    myStr.reverse();
    assert(myStr.cmp("💯olleH💯"));
    myStr.reverse();
    assert(myStr.cmp("💯Hello💯"));

    // repeat
    try myStr.repeat(2);
    assert(myStr.cmp("💯Hello💯💯Hello💯💯Hello💯"));

    // isEmpty
    assert(!myStr.isEmpty());

    // split
    // 返回slice切片
    assert(eql(u8, myStr.split("💯", 0).?, ""));
    assert(eql(u8, myStr.split("💯", 1).?, "Hello"));
    assert(eql(u8, myStr.split("💯", 2).?, ""));
    assert(eql(u8, myStr.split("💯", 3).?, "Hello"));
    assert(eql(u8, myStr.split("💯", 5).?, "Hello"));
    assert(eql(u8, myStr.split("💯", 6).?, ""));

    var splitStr = String.init(arena.allocator());
    defer splitStr.deinit();

    try splitStr.concat("variable='value'");
    assert(eql(u8, splitStr.split("=", 0).?, "variable"));
    assert(eql(u8, splitStr.split("=", 1).?, "'value'"));

    // splitToString
    var newSplit = try splitStr.splitToString("=", 0);
    assert(newSplit != null);
    defer newSplit.?.deinit();

    assert(eql(u8, newSplit.?.str(), "variable"));

    // toLowercase & toUppercase
    myStr.toUppercase();
    assert(myStr.cmp("💯HELLO💯💯HELLO💯💯HELLO💯"));
    myStr.toLowercase();
    assert(myStr.cmp("💯hello💯💯hello💯💯hello💯"));

    // substr
    // 返回截取的子String
    var subStr = try myStr.substr(0, 7);
    defer subStr.deinit();
    assert(subStr.cmp("💯hello💯"));

    // clear
    myStr.clear();
    assert(myStr.len() == 0);
    assert(myStr.size == 0);

    // writer
    const writer = myStr.writer();
    const length = try writer.write("This is a Test!");
    assert(length == 15);

    // owned
    const mySlice = try myStr.toOwned();
    assert(eql(u8, mySlice.?, "This is a Test!"));
    arena.allocator().free(mySlice.?);

    // StringIterator
    var i: usize = 0;
    var iter = myStr.iterator();
    while (iter.next()) |ch| {
        if (i == 0) {
            assert(eql(u8, "T", ch));
        }
        i += 1;
    }

    assert(i == myStr.len());
}

test "init with contents" {
    // Allocator for the String
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit();

    var initial_contents = "String with initial contents!";

    // This is how we create the String with contents at the start
    var myStr = try String.init_with_contents(arena.allocator(), initial_contents);
    assert(eql(u8, myStr.str(), initial_contents));
}
