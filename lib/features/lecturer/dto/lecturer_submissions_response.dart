import '../../../core/models/submission_item.dart';

class LecturerSubmissionsResponse {
  final List<SubmissionItem> items;
  final int? total;

  const LecturerSubmissionsResponse({
    required this.items,
    this.total,
  });

  factory LecturerSubmissionsResponse.fromJson(dynamic data, {String? assignmentId}) {
    if (data is List) {
      return LecturerSubmissionsResponse(items: _parseList(data, assignmentId));
    }
    if (data is Map) {
      final itemsData =
          data['items'] ?? data['data'] ?? data['submissions'] ?? data['results'];
      final totalValue = data['total'] ?? data['count'];
      return LecturerSubmissionsResponse(
        items: _parseList(itemsData, assignmentId),
        total: _parseInt(totalValue),
      );
    }
    return const LecturerSubmissionsResponse(items: []);
  }

  static List<SubmissionItem> _parseList(dynamic data, String? assignmentId) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => _parseItem(Map<String, dynamic>.from(e), assignmentId))
        .toList();
  }

  static SubmissionItem _parseItem(Map<String, dynamic> json, String? assignmentId) {
    if ((json['assignmentId'] == null || json['assignmentId'].toString().isEmpty) &&
        assignmentId != null) {
      json['assignmentId'] = assignmentId;
    }
    return SubmissionItem.fromJson(json);
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
