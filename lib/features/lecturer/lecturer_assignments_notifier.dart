import 'package:flutter/material.dart';
import '../../core/models/lecturer_assignment.dart';
import 'lecturer_assignments_repository.dart';

class LecturerAssignmentsNotifier extends ChangeNotifier {
  final LecturerAssignmentsRepository _repo;
  List<LecturerAssignment> _items = [];
  bool _loading = false;
  String? _error;

  List<LecturerAssignment> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  LecturerAssignmentsNotifier(this._repo);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchAssignments();
    } catch (_) {
      _error = 'Unable to load assignments right now.';
    }
    _loading = false;
    notifyListeners();
  }

  Future<EmailSendResult> create(
    LecturerAssignment assignment, {
    String? description,
    DateTime? dueDate,
    List<String>? assignedEmails,
    bool? isGroup,
    bool sendEmail = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    EmailSendResult emailResult = const EmailSendResult(ok: false);
    try {
      final result = await _repo.createAssignment(
        assignment,
        description: description,
        dueDate: dueDate,
        assignedEmails: assignedEmails,
        isGroup: isGroup,
        sendEmail: sendEmail,
      );
      _items = result.items;
      emailResult = EmailSendResult(ok: result.emailSent, message: result.emailMessage);
    } catch (e) {
      final text = e.toString();
      _error = text.startsWith('ApiError: ') ? text.substring(10) : text;
    }
    _loading = false;
    notifyListeners();
    return emailResult;
  }

  Future<EmailSendResult> resendEmails(LecturerAssignment assignment) async {
    try {
      return await _repo.resendAssignmentEmails(assignment);
    } catch (_) {
      return const EmailSendResult(ok: false, message: 'Unknown error');
    }
  }
}
