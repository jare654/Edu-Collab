import 'package:flutter/material.dart';
import '../../core/models/group.dart';
import 'group_repository.dart';

class GroupNotifier extends ChangeNotifier {
  final GroupRepository _repo;
  List<Group> _items = [];
  bool _loading = false;
  String? _error;

  List<Group> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  GroupNotifier(this._repo);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchGroups();
    } catch (_) {
      _error = 'Unable to load groups right now.';
    }
    _loading = false;
    notifyListeners();
  }

  Future<Group?> createGroup({
    required String name,
    required String courseCode,
    String? description,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final group = await _repo.createGroup(
        name: name,
        courseCode: courseCode,
        description: description,
      );
      _items = [group, ..._items];
      return group;
    } catch (_) {
      _error = 'Unable to create group right now.';
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
