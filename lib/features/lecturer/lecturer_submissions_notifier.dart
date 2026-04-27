import 'package:flutter/material.dart';
import '../../core/models/submission_item.dart';
import 'lecturer_submissions_repository_impl.dart';

class LecturerSubmissionsNotifier extends ChangeNotifier {
  final LecturerSubmissionsRepositoryImpl _repo;
  List<SubmissionItem> _items = [];
  bool _loading = false;
  String? _error;

  List<SubmissionItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  LecturerSubmissionsNotifier(this._repo);

  Future<void> load(String assignmentId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchSubmissions(assignmentId);
    } catch (_) {
      _error = 'Unable to load submissions right now.';
    }
    _loading = false;
    notifyListeners();
  }
}
