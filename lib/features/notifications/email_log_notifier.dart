import 'package:flutter/material.dart';
import '../../core/models/email_log_entry.dart';

class EmailLogNotifier extends ChangeNotifier {
  final List<EmailLogEntry> _entries = [];

  List<EmailLogEntry> get entries => List.unmodifiable(_entries);

  void addEntry(EmailLogEntry entry) {
    _entries.insert(0, entry);
    notifyListeners();
  }

  void addAll(List<EmailLogEntry> items) {
    _entries.insertAll(0, items);
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
