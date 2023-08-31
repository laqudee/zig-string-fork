# Zig String fork from zig-string

> [zig-string](https://github.com/JakubSzark/zig-string)

This library is a UTF-8 compatible **string** library for the **Zig** programming language. 
I made this for the sole purpose to further my experience and understanding of zig.
Also it may be useful for some people who need it (including myself), with future projects. Project is also open for people to add to and improve. Please check the **issues** to view requested features.

# Basic Usage
```zig
const String = @import("./zig-string.zig").String;
// ...

// Use your favorite allocator
var arena = ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();

// Create your String
var myString = String.init(&arena.allocator());
defer myString.deinit();

// Use functions provided
try myString.concat("🔥 Hello!");
_ = myString.pop();
try myString.concat(", World 🔥");

// Success!
assert(myString.cmp("🔥 Hello, World 🔥"));

```