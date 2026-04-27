import '../../core/data/json_asset_loader.dart';
import '../../core/models/submission_item.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error.dart';
import 'dto/lecturer_submissions_response.dart';

class LecturerSubmissionsRepositoryImpl {
  final JsonAssetLoader _loader;
  final ApiClient _client;

  LecturerSubmissionsRepositoryImpl(this._loader, this._client);

  Future<List<SubmissionItem>> fetchSubmissions(String assignmentId) async {
    try {
      final path = ApiEndpoints.submissionsByAssignment(assignmentId);
      final response = await _client.dio.get(path);
      final parsed = LecturerSubmissionsResponse.fromJson(response.data, assignmentId: assignmentId);
      if (parsed.items.isNotEmpty) return parsed.items;
      throw ApiError('Unexpected response format');
    } catch (e) {
      final _ = mapDioError(e);
      final raw = await _loader.loadList('assets/data/lecturer_submissions.json');
      return raw
          .map(SubmissionItem.fromJson)
          .where((item) => item.assignmentId == assignmentId)
          .toList();
    }
  }
}
