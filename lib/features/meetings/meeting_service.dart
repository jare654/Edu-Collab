import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/user.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/feature_flags.dart' as app_flags;
import 'meeting_models.dart';

class MeetingService {
  final ApiClient _client;
  final JitsiMeet _jitsiMeet = JitsiMeet();
  String? _attendanceId;
  String? _activeSessionId;
  bool _createdSession = false;

  MeetingService(this._client);

  Future<void> joinOrCreate({
    required String groupId,
    required User user,
  }) async {
    if (!app_flags.FeatureFlags.enableVideoCalls) return;
    final session = await _resolveSession(groupId, user);
    _activeSessionId = session.id;
    await _launchConference(session, user);
  }

  Future<void> joinOrCreateDirect({
    required String peerEmail,
    required User user,
    String? groupId,
  }) async {
    if (!app_flags.FeatureFlags.enableVideoCalls) return;
    final channel = _buildDirectChannelId(
      currentEmail: user.email,
      peerEmail: peerEmail,
      groupId: groupId,
    );
    final session = await _resolveSession(channel, user);
    _activeSessionId = session.id;
    await _launchConference(session, user);
  }

  Future<void> joinActiveSession({
    required MeetingSession session,
    required User user,
  }) async {
    if (!app_flags.FeatureFlags.enableVideoCalls) return;
    _createdSession = false;
    _activeSessionId = session.id;
    await _launchConference(session, user);
  }

  Future<MeetingSession> _resolveSession(String groupId, User user) async {
    try {
      return await _fetchActiveSession(groupId) ??
          await _createSession(groupId, user);
    } on DioException catch (error) {
      if (_isMissingBackendError(error)) {
        _createdSession = false;
        return _fallbackSession(groupId);
      }
      rethrow;
    }
  }

  Future<MeetingSession?> _fetchActiveSession(String groupId) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.sessions,
        queryParameters: {
          'group_id': 'eq.$groupId',
          'end_time': 'is.null',
          'order': 'start_time.desc',
          'limit': 1,
        },
      );
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return MeetingSession.fromJson(Map<String, dynamic>.from(data.first));
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<MeetingSession> _createSession(String groupId, User user) async {
    _createdSession = true;
    final roomName = 'group-$groupId-${DateTime.now().millisecondsSinceEpoch}';
    final response = await _client.dio.post(
      ApiEndpoints.sessions,
      data: {
        'group_id': groupId,
        'room_name': roomName,
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'created_by': user.id,
      },
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return MeetingSession.fromJson(Map<String, dynamic>.from(data.first));
    }
    if (data is Map) {
      return MeetingSession.fromJson(Map<String, dynamic>.from(data));
    }
    throw StateError('Unable to create session');
  }

  Future<void> _launchConference(MeetingSession session, User user) async {
    if (kIsWeb) {
      await _launchConferenceOnWeb(session, user);
      return;
    }

    final options = JitsiMeetConferenceOptions(
      serverURL: 'https://meet.jit.si',
      room: session.roomName,
      userInfo: JitsiMeetUserInfo(
        displayName: user.name,
        email: user.email,
        avatar: user.avatar,
      ),
      configOverrides: {
        'startWithAudioMuted': true,
        'startWithVideoMuted': false,
        'disableDeepLinking': true,
      },
      featureFlags: {
        'welcomepage.enabled': false,
        'prejoinpage.enabled': true,
        'pip.enabled': true,
        'meeting-name.enabled': false,
        'recording.enabled': false,
        'live-streaming.enabled': false,
        'screen-sharing.enabled': true,
      },
    );

    final listener = JitsiMeetEventListener(
      conferenceJoined: (_) {
        _onJoined(session, user);
      },
      conferenceTerminated: (_, _) {
        _onLeft(user);
      },
      conferenceWillJoin: (_) {},
    );

    await _jitsiMeet.join(options, listener);
  }

  Future<void> _launchConferenceOnWeb(MeetingSession session, User user) async {
    final url = Uri.parse(
      'https://meet.jit.si/${Uri.encodeComponent(session.roomName)}'
      '#config.startWithAudioMuted=true'
      '&config.startWithVideoMuted=false'
      '&userInfo.displayName=${Uri.encodeComponent(user.name)}'
      '&userInfo.email=${Uri.encodeComponent(user.email)}',
    );

    final launched = await launchUrl(url, webOnlyWindowName: '_self');
    if (!launched) {
      throw StateError('Could not open meeting URL');
    }

    // The native Jitsi SDK has no web support in this package, so we treat the
    // browser-open as a completed call event to keep logs and missed-call state
    // consistent instead of leaving sessions permanently "live".
    if (!session.id.startsWith('local-')) {
      await _onJoined(session, user);
      await Future<void>.delayed(const Duration(seconds: 2));
      await _onLeft(user);
    }
  }

  Future<void> _onJoined(MeetingSession session, User user) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.attendance,
        data: {
          'session_id': session.id,
          'user_id': user.id,
          'join_time': DateTime.now().toUtc().toIso8601String(),
          'role': user.role.name,
        },
        options: Options(headers: {'Prefer': 'return=representation'}),
      );
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        _attendanceId = data.first['id']?.toString();
      } else if (data is Map) {
        _attendanceId = data['id']?.toString();
      }
    } catch (_) {
      // ignore attendance errors
    }
  }

  bool _isMissingBackendError(DioException error) {
    return error.response?.statusCode == 404;
  }

  MeetingSession _fallbackSession(String groupId) {
    final startedAt = DateTime.now().toUtc();
    return MeetingSession(
      id: 'local-${startedAt.millisecondsSinceEpoch}',
      groupId: groupId,
      roomName: 'group-$groupId-${startedAt.millisecondsSinceEpoch}',
      startTime: startedAt,
    );
  }

  Future<void> _onLeft(User user) async {
    if (_attendanceId != null) {
      try {
        await _client.dio.patch(
          ApiEndpoints.attendance,
          queryParameters: {'id': 'eq.${_attendanceId!}'},
          data: {'leave_time': DateTime.now().toUtc().toIso8601String()},
        );
      } catch (_) {
        // ignore
      }
    }

    if (_createdSession && _activeSessionId != null) {
      try {
        await _client.dio.patch(
          ApiEndpoints.sessions,
          queryParameters: {'id': 'eq.${_activeSessionId!}'},
          data: {'end_time': DateTime.now().toUtc().toIso8601String()},
        );
      } catch (_) {
        // ignore
      }
    }

    _attendanceId = null;
    _activeSessionId = null;
    _createdSession = false;
  }

  static bool isDirectChannelId(String value) => value.startsWith('dm__');

  static List<String> parseDirectParticipantEmails(String value) {
    if (!isDirectChannelId(value)) return const [];
    final parts = value.split('__');
    if (parts.length < 3) return const [];
    return [Uri.decodeComponent(parts[1]), Uri.decodeComponent(parts[2])];
  }

  String _buildDirectChannelId({
    required String currentEmail,
    required String peerEmail,
    String? groupId,
  }) {
    final a = currentEmail.trim().toLowerCase();
    final b = peerEmail.trim().toLowerCase();
    final pair = [a, b]..sort();
    final scope = Uri.encodeComponent(groupId ?? 'global');
    return 'dm__${Uri.encodeComponent(pair.first)}__${Uri.encodeComponent(pair.last)}__$scope';
  }
}
