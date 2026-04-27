import '../../core/storage/local_cache.dart';
import '../../core/models/assignment.dart';

class AssignmentsLocalCache {
  final LocalCache<List<Assignment>> _cache = LocalCache<List<Assignment>>();
  static const _key = 'student_assignments_';

  String _scopedKey(String userId) => '$_key$userId';

  List<Assignment>? getCached(String userId) => _cache.get(_scopedKey(userId));
  void setCached(String userId, List<Assignment> items) => _cache.set(_scopedKey(userId), items);
  bool hasCache(String userId) => _cache.contains(_scopedKey(userId));
}
