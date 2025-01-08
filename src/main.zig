const std = @import("std");
const PORT = 2098;

pub fn main() !void {
    const addr = std.net.Address.parseIp4("127.0.0.1", PORT) catch |err| {
        std.debug.print("An error occurred whil resolving the IP address: {}\n", .{err});
        return;
    };

    var server = try addr.listen(.{});
    start_server(&server);
}

fn start_server(server: *std.net.Server) void {
    std.debug.print("Server listening on port {}", .{PORT});
    while (true) {
        var connection = server.accept() catch |err| {
            std.debug.print("connection to client intterupted: {}\n", .{err});
            continue;
        };
        defer connection.stream.close();

        var read_buff: [1024]u8 = undefined;
        var http_server = std.http.Server.init(connection, &read_buff);

        var request = http_server.receiveHead() catch |err| {
            std.debug.print("Could not read head: {}\n", .{err});
            continue;
        };
        handle_request(&request) catch |err| {
            std.debug.print("Could not handle request {}\n", .{err});
            continue;
        };
    }
}

fn handle_request(request: *std.http.Server.Request) !void {
    std.debug.print("Handling requeset for {s}\n", .{request.head.target});
    try request.respond("Hello http!\n", .{});
}
