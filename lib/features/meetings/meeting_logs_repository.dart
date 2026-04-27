import 'dart:async';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import 'meeting_models.dart';

class MeetingLogEntry {
  final MeetingSession session;
  final List<MeetingAttendance> attendance;

  const MeetingLogEntry({required this.session, required this.attendance});

  int get attendeeCount => attendance.length;

  Duration get averageDuration {
    if (attendance.isEmpty) return Duration.zero;
    final total = attendance.fold<Duration>(Duration.zero, (sum, a) {
      final end = a.leaveTime ?? DateTime.now();
      return sum + end.difference(a.joinTime);
    });
    return Duration(seconds: total.inSeconds ~/ attendance.length);
  }
}

class MeetingLogsRepository {
  final ApiClient _client;
  StreamController<List<MeetingLogEntry>>? _controller;
  RealtimeChannel? _channel;

  MeetingLogsRepository(this._client);

  Future<List<MeetingLogEntry>> fetchSessions() async {
    try {
      final response = await _client.dio
          .get(
            ApiEndpoints.sessions,
            queryParameters: {
              'order': 'start_time.desc',
              'select':
                  'id,group_id,room_name,start_time,end_time,attendance:attendance(id,session_id,user_id,role,join_time,leave_time,user:users(id,email,user_metadata))',
            },
            options: Options(headers: {'Accept': 'application/json'}),
          )
          .timeout(const Duration(seconds: 8));
      final data = response.data;
      if (data is! List) return [];
      return data.map<MeetingLogEntry>((row) {
        final session = MeetingSession.fromJson(Map<String, dynamic>.from(row));
        final attendanceRaw = (row['attendance'] as List?) ?? [];
        final attendance = attendanceRaw
            .map((a) => MeetingAttendance.fromJson(Map<String, dynamic>.from(a)))
            .toList();
        return MeetingLogEntry(session: session, attendance: attendance);
      }).toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return [];
      rethrow;
    } on TimeoutException {
      return [];
    }
  }

  Stream<List<MeetingLogEntry>> watchSessions() {
    _controller ??= StreamController<List<MeetingLogEntry>>.broadcast(
      onListen: _startRealtime,
      onCancel: _stopRealtime,
    );
    return _controller!.stream;
  }

  void _startRealtime() {
    _controller?.add([]);
    _emitLatest();
    _channel ??= Supabase.instance.client.channel('meeting-logs');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'sessions',
          callback: (_) => _emitLatest(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attendance',
          callback: (_) => _emitLatest(),
        )
        .subscribe();
  }

  void _stopRealtime() {
    if (_controller?.hasListener ?? false) return;
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<void> _emitLatest() async {
    if (_controller == null) return;
    try {
      final items = await fetchSessions();
      _controller?.add(items);
    } catch (_) {
      _controller?.add([]);
    }
  }
}
