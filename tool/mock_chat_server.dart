import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() async {
  final handler = webSocketHandler((webSocket) {
    webSocket.stream.listen((message) {
      try {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        final payload = {
          'groupId': data['groupId'] ?? 'g1',
          'sender': data['sender'] ?? 'Mock Bot',
          'content': data['content'] ?? 'ok',
          'time': DateTime.now().toIso8601String(),
        };
        webSocket.sink.add(jsonEncode(payload));
      } catch (_) {
        webSocket.sink.add(jsonEncode({
          'groupId': 'g1',
          'sender': 'Mock Bot',
          'content': message.toString(),
          'time': DateTime.now().toIso8601String(),
        }));
      }
    });
  });

  final server = await shelf_io.serve(
    (Request request) {
      if (request.url.path == 'ws') {
        return handler(request);
      }
      return Response.ok('ok');
    },
    InternetAddress.loopbackIPv4,
    8081,
  );

  stdout.writeln('Mock chat server running on ws://localhost:${server.port}/ws');
}
