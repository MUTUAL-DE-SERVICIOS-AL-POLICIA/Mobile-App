import 'package:flutter/foundation.dart';

class AppSessionState extends ChangeNotifier {
  bool _allowAutoBiometric = true;

  bool get allowAutoBiometric => _allowAutoBiometric;

  void disableAutoBiometricUntilColdStart() {
    if (_allowAutoBiometric) {
      _allowAutoBiometric = false;
      notifyListeners();
    }
  }
  void enableAutoBiometric() {
    if (!_allowAutoBiometric) {
      _allowAutoBiometric = true;
      notifyListeners();
    }
  }
}
