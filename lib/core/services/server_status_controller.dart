import 'package:flutter/material.dart';

class ServerStatusController extends ChangeNotifier {
  bool _serverUnavailable = false;

  bool get serverUnavailable => _serverUnavailable;

  void markUnavailable() {
    if (_serverUnavailable) return;
    _serverUnavailable = true;
    notifyListeners();
  }

  void clearUnavailable() {
    if (!_serverUnavailable) return;
    _serverUnavailable = false;
    notifyListeners();
  }
}
