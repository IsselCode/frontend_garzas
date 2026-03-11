import 'package:flutter/services.dart';

class RegexService {
  RegexService._();

  // Allowlist para nombres de usuario compuestos solo por letras.
  static final RegExp usernamePattern = RegExp(r'^[A-Za-z]+$');

  // Formatter para impedir el ingreso de caracteres no permitidos.
  static final TextInputFormatter usernameFormatter = FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'));

  static bool isValidUsername(String value) => usernamePattern.hasMatch(value);

  static String? usernameValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'El usuario es obligatorio';
    }

    if (!isValidUsername(text)) {
      return 'Solo se permiten letras';
    }

    return null;
  }

}
