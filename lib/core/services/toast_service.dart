import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  ToastificationItem? _activeErrorToast;

  void error(String text) {
    final previousToast = _activeErrorToast;
    if (previousToast != null) {
      toastification.dismiss(previousToast, showRemoveAnimation: false);
    }

    _activeErrorToast = toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: const Text("¡Ups!"),
      description: Text(text),
      alignment: Alignment.topLeft,
      autoCloseDuration: const Duration(seconds: 4),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      icon: const Icon(Icons.error_outline),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: lowModeShadow,
      showProgressBar: true,
      dragToClose: true,
    );
  }

  void success(String text) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: const Text("¡Bien!"),
      description: Text(text),
      alignment: Alignment.topLeft,
      autoCloseDuration: const Duration(seconds: 4),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      icon: const Icon(Icons.verified_outlined),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: lowModeShadow,
      showProgressBar: true,
      dragToClose: true,
    );
  }
}
