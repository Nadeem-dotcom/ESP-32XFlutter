import 'package:flutter/foundation.dart';

class CarIsVisible with ChangeNotifier {
  bool _is_visible = true;

  get is_visible => _is_visible; 

  set setValue (String value) {
    if (value == '0') {
    notifyListeners();
      right();
    }
    else if (value == '1') {
    notifyListeners();
      wrong();
    }
  }
  void right () {
    _is_visible = true;
  }
  void wrong() {
    _is_visible = false;
  }
}

