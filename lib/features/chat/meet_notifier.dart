import 'dart:async';
import 'package:flutter/material.dart';

class MeetNotifier extends ChangeNotifier {
  DateTime? _nextMeeting;
  String _title = '';
  String _location = '';
  Timer? _timer;

  DateTime? get nextMeeting => _nextMeeting;
  String get title => _title;
  String get location => _location;
  bool get isNativeAvailable => true;

  String get countdown {
    if (_nextMeeting == null) return 'No meet scheduled';
    final diff = _nextMeeting!.difference(DateTime.now());
    if (diff.isNegative) return 'Started';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  void scheduleMeet({
    required DateTime time,
    required String title,
    required String location,
  }) {
    _nextMeeting = time;
    _title = title;
    _location = location;
    _startTicker();
    notifyListeners();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => notifyListeners());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
