const std = @import("std");
const assert = std.debug.assert;
const http = std.http;
const net = std.net;
const print = std.debug.print;

pub fn main() !void {
    const addr = net.Address.parseIp4("127.0.0.1", 8080) catch |err| {
        print("Error occured during ip resolution: {}\n", .{err});
        return;
    };

    var server = try addr.listen(.{});
    startServer(&server);
}

fn startServer(server: *net.Server) void {
    while (true) {
        var connection = server.accept() catch |err| {
            print("Connection interrupted: {}\n", .{err});
            continue;
        };
        defer connection.stream.close();

        var readBuffer: [8192]u8 = undefined;
        var httpServer = http.Server.init(connection, &readBuffer);

        var request = httpServer.receiveHead() catch |err| {
            print("Unable to read head: {}\n", .{err});
            continue;
        };
        handleRequest(&request) catch |err| {
            print("Unable to handle request: {}\n", .{err});
        };
    }
}

fn handleRequest(request: *http.Server.Request) !void {
    try request.respond("Hello World!\n", .{});
}
