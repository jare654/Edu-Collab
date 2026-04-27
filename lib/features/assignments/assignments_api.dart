import '../../core/models/assignment.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error.dart';
import '../../core/feature_flags.dart';
import 'package:dio/dio.dart';
import 'dto/assignment_submit_response.dart';
import '../../core/storage/session_store.dart';
import '../../core/network/api_config.dart';
import 'dto/assignment_submission_request.dart';
import 'dart:typed_data';

class AssignmentsApi {
  final ApiClient _client;
  final SessionStore _session;

  AssignmentsApi(this._client, this._session);

  Future<List<Assignment>> fetchStudentAssignments() async {
    final user = await _session.read();
    final email = user?.email;
    if (email == null || email.isEmpty) {
      return [];
    }
    final normalizedEmail = email.trim().toLowerCase();
    final containsExpr = '{"$normalizedEmail"}';
    final encodedContains = Uri.encodeQueryComponent(containsExpr);
    try {
      final response = await _client.dio.get(
        '${ApiEndpoints.assignments}?assigned_emails=cs.$encodedContains&order=due_date.asc',
      );
      if (response.data is List) {
        final items = (response.data as List)
            .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
            .toList();
        if (items.isNotEmpty) {
          return items;
        }
      }
      // Fallback path: fetch all visible assignments and filter client-side by normalized email.
      final allResponse = await _client.dio.get(
        '${ApiEndpoints.assignments}?order=due_date.asc',
      );
      if (allResponse.data is List) {
        final allItems = (allResponse.data as List)
            .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
            .toList();
        return allItems.where((a) => a.assignedEmails.contains(normalizedEmail)).toList();
      }
      throw ApiError('Unexpected assignments response format');
    } catch (e) {
      final _ = mapDioError(e);
      return [];
    }
  }

  Future<AssignmentSubmitResponse> submitAssignment(
    String assignmentId, {
    String? note,
    List<MultipartFile> files = const [],
    Uint8List? fileBytes,
    String? filename,
  }) async {
    final user = await _session.read();
    final studentId = user?.id ?? 'unknown-student';
    final safeName = (filename?.isNotEmpty ?? false)
        ? filename!
        : (files.isNotEmpty ? (files.first.filename ?? 'submission.zip') : 'submission.zip');
    final storagePath = '$studentId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final shouldUpload = FeatureFlags.enableUploadStub && (fileBytes?.isNotEmpty ?? false);
    final submissionUrl = shouldUpload ? '${ApiConfig.storagePublicBase}/$storagePath' : '';

    if (shouldUpload) {
      try {
        final uploadUrl = '${ApiConfig.storageBaseUrl}/object/${ApiConfig.storageBucket}/$storagePath';
        final uploadResponse = await _client.dio.put(
          uploadUrl,
          data: fileBytes,
          options: Options(headers: {
            'x-upsert': 'true',
            Headers.contentTypeHeader: 'application/octet-stream',
          }),
        );
        if ((uploadResponse.statusCode ?? 500) >= 400) {
          throw ApiError('Upload failed (${uploadResponse.statusCode})');
        }
      } catch (e) {
        throw ApiError('Upload failed');
      }
    }

    final request = AssignmentSubmissionRequest(
      assignmentId: assignmentId,
      studentId: studentId,
      submissionUrl: submissionUrl,
      submittedAt: DateTime.now(),
    );
    final response = await _client.dio.post(
      ApiEndpoints.submissions,
      data: request.toJson(),
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    if (response.data is List && (response.data as List).isNotEmpty) {
      return AssignmentSubmitResponse.fromJson((response.data as List).first as Map<String, dynamic>);
    }
    if (response.data is Map<String, dynamic>) {
      return AssignmentSubmitResponse.fromJson(response.data as Map<String, dynamic>);
    }
    return const AssignmentSubmitResponse(submissionId: 'local', status: 'submitted');
  }
}
