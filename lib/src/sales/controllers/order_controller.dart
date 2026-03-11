import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class OrderController extends ChangeNotifier {

  TabSwitcherAlignStates _state = TabSwitcherAlignStates.left;
  TabSwitcherAlignStates get state => _state;
  set state(TabSwitcherAlignStates value) {
    _state = value;
    notifyListeners();
  }

  TextEditingController quantityController = TextEditingController();

}