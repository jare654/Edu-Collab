import 'package:flutter/material.dart';

import '../../core/models/notification_item.dart';
import 'notifications_repository.dart';

class NotificationsNotifier extends ChangeNotifier {
  NotificationsRepository _repo;

  NotificationsNotifier(this._repo);

  void updateRepository(NotificationsRepository repo) {
    _repo = repo;
  }

  List<NotificationItem> _items = const [];
  bool _loading = false;
  String? _error;
  String? _lastLoadedEmail;
  bool _hasLoadedForCurrentEmail = false;

  List<NotificationItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  int get assignmentCount => _items.where(_isAssignmentNotification).length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchNotifications();
      _hasLoadedForCurrentEmail = true;
    } catch (e) {
      _error = e.toString();
      _items = const [];
      _hasLoadedForCurrentEmail = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> ensureFreshFor(String? email) async {
    final normalized = email?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      _lastLoadedEmail = null;
      _hasLoadedForCurrentEmail = false;
      _items = const [];
      _error = null;
      notifyListeners();
      return;
    }
    if (_lastLoadedEmail == normalized && (_hasLoadedForCurrentEmail || _loading)) {
      return;
    }
    _lastLoadedEmail = normalized;
    _hasLoadedForCurrentEmail = false;
    await load();
  }

  bool hasNewAssignment(String title) {
    final normalizedTitle = _normalize(title);
    for (final item in _items.where(_isAssignmentNotification)) {
      if (_normalize(item.title).contains(normalizedTitle)) {
        return true;
      }
      if (_normalize(item.body).contains(normalizedTitle)) {
        return true;
      }
    }
    return false;
  }

  bool _isAssignmentNotification(NotificationItem item) {
    final text = _normalize('${item.title} ${item.body}');
    return text.contains('assignment');
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}
