import 'package:flutter/material.dart';
import '../../core/models/resource.dart';
import 'resources_repository.dart';

class ResourcesNotifier extends ChangeNotifier {
  final ResourcesRepository _repo;
  List<ResourceItem> _items = [];
  bool _loading = false;
  String? _error;

  List<ResourceItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  ResourcesNotifier(this._repo);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchResources();
    } catch (_) {
      _error = 'Unable to load resources right now.';
    }
    _loading = false;
    notifyListeners();
  }
}
