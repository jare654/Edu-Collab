import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  bool _online = true;

  bool get isOnline => _online;

  Future<bool> check() async => _online;

  void setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    notifyListeners();
  }
}
