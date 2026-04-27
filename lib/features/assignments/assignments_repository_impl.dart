import 'package:dio/dio.dart';
import '../../core/models/assignment.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/storage/session_store.dart';
import 'assignments_api.dart';
import 'assignments_local_cache.dart';
import 'assignments_repository.dart';
import 'dart:typed_data';

class AssignmentsRepositoryImpl implements AssignmentsRepository {
  final AssignmentsApi _api;
  final AssignmentsLocalCache _cache;
  final ConnectivityService _connectivity;
  final SessionStore _session;

  AssignmentsRepositoryImpl(this._api, this._cache, this._connectivity, this._session);

  @override
  Future<List<Assignment>> fetchStudentAssignments() async {
    final user = await _session.read();
    final userKey = user?.id ?? 'anonymous';
    final online = await _connectivity.check();
    if (online) {
      final items = await _api.fetchStudentAssignments();
      _cache.setCached(userKey, items);
      return items;
    }
    final cached = _cache.getCached(userKey);
    if (cached != null) return cached;
    return [];
  }

  @override
  Future<void> submitAssignment(
    String assignmentId, {
    String? note,
    List<MultipartFile> files = const [],
    Uint8List? fileBytes,
    String? filename,
  }) async {
    final online = await _connectivity.check();
    if (!online) {
      throw StateError('Offline');
    }
    await _api.submitAssignment(
      assignmentId,
      note: note,
      files: files,
      fileBytes: fileBytes,
      filename: filename,
    );
    final user = await _session.read();
    final userKey = user?.id ?? 'anonymous';
    final current = _cache.getCached(userKey) ?? await _api.fetchStudentAssignments();
        final updated = current
        .map(
          (a) => a.id == assignmentId
              ? Assignment(
                  id: a.id,
                  title: a.title,
                  course: a.course,
                  dueDate: a.dueDate,
                  status: AssignmentStatus.submitted,
                  isGroup: a.isGroup,
                  assignedEmails: a.assignedEmails,
                  description: a.description,
                  attachmentUrl: a.attachmentUrl,
                )
              : a,
        )
        .toList();
    _cache.setCached(userKey, updated);
  }
}
