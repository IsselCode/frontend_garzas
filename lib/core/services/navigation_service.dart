import 'package:flutter/material.dart';

class NavigationService {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void navigateTo(Widget route) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => route,
        settings: RouteSettings(name: route.runtimeType.toString()),
      )
    );
  }

  void pushReplacement(Widget route) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => route,
        settings: RouteSettings(name: route.runtimeType.toString()),
      )
    );
  }

  void pushAndRemoveUntil(Widget route) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => route,
        settings: RouteSettings(name: route.runtimeType.toString()),
      ),
      (route) => false,
    );
  }

  void popUntilWidget(Type widgetType) {
    navigatorKey.currentState?.popUntil((route) => route.settings.name == widgetType.toString(),);
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }

}