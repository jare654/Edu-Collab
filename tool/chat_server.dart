import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> args) async {
  final host = args.contains('--host')
      ? args[args.indexOf('--host') + 1]
      : '0.0.0.0';
  final port = args.contains('--port')
      ? int.parse(args[args.indexOf('--port') + 1])
      : 8081;

  final rooms = <String, Set<WebSocketChannel>>{};

  final handler = webSocketHandler((WebSocketChannel channel, String? protocol) {
    String groupId = 'default';
    String user = 'unknown';

    channel.stream.listen((message) {
      try {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        groupId = (data['groupId'] ?? groupId).toString();
        user = (data['sender'] ?? user).toString();
        rooms.putIfAbsent(groupId, () => <WebSocketChannel>{});
        rooms[groupId]!.add(channel);
        _broadcast(rooms[groupId]!, jsonEncode(data));
      } catch (_) {
        // Ignore invalid payloads
      }
    }, onDone: () {
      rooms[groupId]?.remove(channel);
    });
  });

  await io.serve(
    Pipeline().addMiddleware(logRequests()).addHandler((Request request) {
      if (request.url.path == 'ws') {
        return handler(request);
      }
      return Response.ok('Chat server running');
    }),
    host,
    port,
  );

  stdout.writeln('Chat server running on ws://$host:$port/ws');
}

void _broadcast(Set<WebSocketChannel> clients, String message) {
  for (final c in clients) {
    c.sink.add(message);
  }
}
