import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/models/assignment.dart';
import 'assignments_repository.dart';
import 'dart:typed_data';

class StudentAssignmentsNotifier extends ChangeNotifier {
  final AssignmentsRepository _repo;
  List<Assignment> _items = [];
  bool _loading = false;
  String? _error;
  String? _lastUserId;

  List<Assignment> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  StudentAssignmentsNotifier(this._repo);

  Future<void> ensureFreshForUser(String? userId) async {
    final normalized = userId?.trim();
    if (normalized == null || normalized.isEmpty) {
      if (_lastUserId != null || _items.isNotEmpty || _error != null) {
        _lastUserId = null;
        _items = [];
        _error = null;
        notifyListeners();
      }
      return;
    }
    if (_lastUserId == normalized || _loading) {
      return;
    }
    _lastUserId = normalized;
    await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchStudentAssignments();
    } catch (e) {
      _error = 'No offline data available.'; 
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> submit(
    String assignmentId, {
    String? note,
    List<MultipartFile> files = const [],
    Uint8List? fileBytes,
    String? filename,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      await _repo.submitAssignment(
        assignmentId,
        note: note,
        files: files,
        fileBytes: fileBytes,
        filename: filename,
      );
      _items = await _repo.fetchStudentAssignments();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Unable to submit assignment.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
