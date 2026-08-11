import 'package:flutter/foundation.dart';

class WebUpdateNotifier extends ChangeNotifier {
  bool hasUpdate = false;

  void notify() {
    hasUpdate = true;
    notifyListeners();
  }
}
