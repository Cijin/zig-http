const std = @import("std");
const assert = std.debug.assert;
const http = std.http;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = std.Uri.parse("https://whatthecommit.com/index.txt") catch unreachable;

    var headers = http.Header{ .allocator = allocator };
    defer headers.deinit();

    try headers.append("accept", "/*");
    var request = try client.request(.GET, uri, headers, .{});
    defer request.deinit();

    try request.start();
    try request.wait();
    const body = request.reader().readAllAlloc(allocator, 8192) catch unreachable;
    defer allocator.free(body);

    std.log.info("{s}", .{body});
}
