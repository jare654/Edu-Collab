import '../../core/data/json_asset_loader.dart';
import '../../core/models/lecturer_assignment.dart';
import 'lecturer_assignments_repository.dart';
import '../../core/storage/local_cache.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error.dart';
import '../../core/network/api_config.dart';
import '../assignments/dto/assignment_create_request.dart';
import 'package:dio/dio.dart';

class LecturerAssignmentsRepositoryImpl implements LecturerAssignmentsRepository {
  final JsonAssetLoader _loader;
  final ApiClient _client;
  final LocalCache<List<LecturerAssignment>> _cache = LocalCache<List<LecturerAssignment>>();
  static const _key = 'lecturer_assignments';

  LecturerAssignmentsRepositoryImpl(this._loader, this._client);

  @override
  Future<List<LecturerAssignment>> fetchAssignments() async {
    final cached = _cache.get(_key);
    if (cached != null) return cached;
    try {
      final response = await _client.dio.get(ApiEndpoints.assignments);
      if (response.data is List) {
        final items = (response.data as List)
            .map((e) => LecturerAssignment.fromJson(e as Map<String, dynamic>))
            .toList();
        _cache.set(_key, items);
        return items;
      }
      throw ApiError('Unexpected response format');
    } catch (e) {
      final _ = mapDioError(e);
      final raw = await _loader.loadList('assets/data/lecturer_assignments.json');
      final items = raw.map(LecturerAssignment.fromJson).toList();
      _cache.set(_key, items);
      return items;
    }
  }

  @override
  Future<AssignmentCreateResult> createAssignment(
    LecturerAssignment assignment, {
    String? description,
    DateTime? dueDate,
    List<String>? assignedEmails,
    bool? isGroup,
    bool sendEmail = false,
  }) async {
    final normalizedEmails = (assignedEmails ?? const <String>[])
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    try {
      final req = AssignmentCreateRequest(
        title: assignment.title,
        courseId: assignment.course,
        description: description ?? '',
        dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
        assignedEmails: normalizedEmails,
        isGroup: isGroup,
      );
      final response = await _client.dio.post(
        ApiEndpoints.assignments,
        data: req.toJson(),
        options: Options(headers: {'Prefer': 'return=representation'}),
      );
      if (response.data is List && (response.data as List).isNotEmpty) {
        final created = LecturerAssignment.fromJson((response.data as List).first as Map<String, dynamic>);
        bool emailSent = false;
        String? emailMessage;
        await _createNotifications(
          created: created,
          assignedEmails: normalizedEmails,
          dueDate: dueDate,
        );
        if (sendEmail && normalizedEmails.isNotEmpty) {
          final result = await _sendAssignmentEmails(
                assignmentId: created.id,
                title: created.title,
                courseId: created.course,
                description: description ?? '',
                dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
                assignedEmails: normalizedEmails,
                isGroup: isGroup ?? false,
              );
          emailSent = result.ok;
          emailMessage = result.message;
        }
        final current = await fetchAssignments();
        final updated = [created, ...current];
        _cache.set(_key, updated);
        return AssignmentCreateResult(items: updated, emailSent: emailSent, emailMessage: emailMessage);
      }
      if (response.data is Map<String, dynamic>) {
        final created = LecturerAssignment.fromJson(response.data as Map<String, dynamic>);
        bool emailSent = false;
        String? emailMessage;
        await _createNotifications(
          created: created,
          assignedEmails: normalizedEmails,
          dueDate: dueDate,
        );
        if (sendEmail && normalizedEmails.isNotEmpty) {
          final result = await _sendAssignmentEmails(
                assignmentId: created.id,
                title: created.title,
                courseId: created.course,
                description: description ?? '',
                dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
                assignedEmails: normalizedEmails,
                isGroup: isGroup ?? false,
              );
          emailSent = result.ok;
          emailMessage = result.message;
        }
        final current = await fetchAssignments();
        final updated = [created, ...current];
        _cache.set(_key, updated);
        return AssignmentCreateResult(items: updated, emailSent: emailSent, emailMessage: emailMessage);
      }
      throw ApiError('Unexpected assignment create response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> _createNotifications({
    required LecturerAssignment created,
    required List<String>? assignedEmails,
    required DateTime? dueDate,
  }) async {
    if (assignedEmails == null || assignedEmails.isEmpty) return;
    final due = (dueDate ?? created.dueDate)?.toIso8601String();
    final body = due == null
        ? 'New assignment: ${created.title}'
        : 'New assignment: ${created.title} • Due ${due.substring(0, 10)}';
    for (final email in assignedEmails) {
      try {
        await _client.dio.post(
          ApiEndpoints.notifications,
          data: {
            'title': 'New Assignment',
            'body': body,
            'recipient_email': email,
          },
        );
      } catch (_) {
        // ignore notification errors
      }
    }
  }

  Future<EmailSendResult> _sendAssignmentEmails({
    required String assignmentId,
    required String title,
    required String courseId,
    required String description,
    required DateTime dueDate,
    required List<String> assignedEmails,
    required bool isGroup,
  }) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.functionsBaseUrl}/send-assignment-email',
        data: {
          'assignment_id': assignmentId,
          'title': title,
          'course_id': courseId,
          'description': description,
          'due_date': dueDate.toIso8601String(),
          'assigned_emails': assignedEmails,
          'is_group': isGroup,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );
      if (response.data is Map && (response.data as Map)['ok'] == true) {
        return const EmailSendResult(ok: true);
      }
      if (response.data is Map) {
        final map = response.data as Map;
        final err = map['error']?.toString() ?? map['message']?.toString() ?? map.toString();
        return EmailSendResult(ok: false, message: _friendlyEmailError(err));
      }
      return EmailSendResult(ok: false, message: response.data?.toString());
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        final msg = data is Map
            ? (data['error']?.toString() ?? data['message']?.toString() ?? data.toString())
            : (data?.toString() ?? e.message ?? 'Email send failed');
        return EmailSendResult(ok: false, message: _friendlyEmailError(msg));
      }
      return EmailSendResult(ok: false, message: _friendlyEmailError(e.toString()));
    }
  }

  @override
  Future<EmailSendResult> resendAssignmentEmails(LecturerAssignment assignment) async {
    final emails = assignment.assignedEmails;
    if (emails == null || emails.isEmpty) {
      return const EmailSendResult(ok: false, message: 'No recipient emails');
    }
    final result = await _sendAssignmentEmails(
      assignmentId: assignment.id,
      title: assignment.title,
      courseId: assignment.course,
      description: assignment.description ?? '',
      dueDate: assignment.dueDate ?? DateTime.now().add(const Duration(days: 7)),
      assignedEmails: emails,
      isGroup: assignment.isGroup,
    );
    return result;
  }

  String _friendlyEmailError(String raw) {
    final text = raw.trim();
    final lower = text.toLowerCase();
    if (lower.contains('you can only send testing emails to your own email address') ||
        lower.contains('verify a domain at resend.com/domains')) {
      return 'Assignment saved, but email failed. Your Resend domain is not verified yet. Students can still see this assignment in-app.';
    }
    return text;
  }
}
