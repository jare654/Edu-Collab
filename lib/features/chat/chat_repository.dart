import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:drift/drift.dart';
import '../../core/models/message.dart';
import '../../core/feature_flags.dart';
import '../../core/network/api_config.dart';
import 'chat_database.dart';

class ChatRepository extends ChangeNotifier {
  final ChatDatabase _db;
  String _serverUrl = ApiConfig.chatWsUrl;
  WebSocketChannel? _channel;
  String? _activeGroup;
  String? _activeUser;

  final Map<String, List<MessageItem>> _messages = {};

  ChatRepository(this._db);

  String get serverUrl => _serverUrl;
  bool get isConnected => _channel != null;

  void updateServerUrl(String url) {
    _serverUrl = url;
    notifyListeners();
  }

  void connect(String groupId, String user, {String? token}) {
    if (_activeGroup == groupId && _activeUser == user && _channel != null) return;
    _channel?.sink.close();
    _activeGroup = groupId;
    _activeUser = user;
    if (FeatureFlags.disableChatWs) {
      _channel = null;
      notifyListeners();
      return;
    }
    try {
      final uri = Uri.parse(_serverUrl);
      final query = Map<String, String>.from(uri.queryParameters);
      if (token != null && token.isNotEmpty) {
        query['token'] = token;
      }
      query['groupId'] = groupId;
      query['user'] = user;
      final wsUri = uri.replace(queryParameters: query);
      _channel = WebSocketChannel.connect(wsUri);
      _channel!.stream.listen((event) {
        try {
          final data = jsonDecode(event as String) as Map<String, dynamic>;
          final gid = data['groupId']?.toString() ?? groupId;
          final sender = data['sender']?.toString() ?? 'Unknown';
          final content = data['content']?.toString() ?? '';
          final time = DateTime.tryParse(data['time']?.toString() ?? '') ?? DateTime.now();
          final isMine = sender == _activeUser;
          final incoming = MessageItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: sender,
            content: content,
            time: time,
            isMine: isMine,
          );
          messagesFor(gid).add(incoming);
          _persistMessage(gid, incoming);
          notifyListeners();
        } catch (_) {}
      }, onError: (_) {
        _channel = null;
        notifyListeners();
      }, onDone: () {
        _channel = null;
        notifyListeners();
      });
      notifyListeners();
    } catch (_) {
      _channel = null;
      notifyListeners();
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _activeGroup = null;
    _activeUser = null;
    notifyListeners();
  }

  List<MessageItem> messagesFor(String groupId) {
    if (_messages.containsKey(groupId)) {
      return _messages[groupId]!;
    }
    _messages[groupId] = [
      MessageItem(
        id: 'm1',
        sender: 'Mekdes Alemu',
        content: 'Has everyone seen the latest brief for the Addis Heritage report?',
        time: DateTime.now().subtract(const Duration(minutes: 30)),
        isMine: false,
      ),
      MessageItem(
        id: 'm2',
        sender: 'You',
        content: 'Yes! I can cover the layout draft by tonight.',
        time: DateTime.now().subtract(const Duration(minutes: 10)),
        isMine: true,
      ),
    ];
    _loadCached(groupId);
    return _messages[groupId]!;
  }

  void sendMessage(String groupId, String sender, String text) {
    final list = messagesFor(groupId);
    final outgoing = MessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: sender,
      content: text,
      time: DateTime.now(),
      isMine: true,
    );
    list.add(outgoing);
    notifyListeners();
    _persistMessage(groupId, outgoing);
    final payload = jsonEncode({
      'groupId': groupId,
      'sender': sender,
      'content': text,
      'time': DateTime.now().toIso8601String(),
    });
    _channel?.sink.add(payload);
  }

  Future<void> _loadCached(String groupId) async {
    final rows = await _db.getMessages(groupId);
    if (rows.isEmpty) return;
    _messages[groupId] = rows
        .map((row) => MessageItem(
              id: row.id,
              sender: row.sender,
              content: row.content,
              time: DateTime.fromMillisecondsSinceEpoch(row.timeMs),
              isMine: row.isMine,
            ))
        .toList();
    notifyListeners();
  }

  Future<void> _persistMessage(String groupId, MessageItem message) async {
    await _db.upsertMessage(
      ChatMessagesCompanion.insert(
        id: message.id,
        groupId: groupId,
        sender: message.sender,
        content: message.content,
        timeMs: message.time.millisecondsSinceEpoch,
        isMine: Value(message.isMine),
      ),
    );
  }
}
