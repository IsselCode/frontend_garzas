import 'package:flutter/services.dart';

class RegexService {
  RegexService._();

  // Allowlist para nombres de usuario compuestos solo por letras.
  static final RegExp usernamePattern = RegExp(r'^[A-Za-z]+$');
  static final RegExp positiveNumberPattern = RegExp(r'^\d+(\.\d+)?$');
  static final RegExp negativeNumberPattern = RegExp(r'^-?\d+(\.\d+)?$');

  // Formatter para impedir el ingreso de caracteres no permitidos.
  static final TextInputFormatter usernameFormatter = FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'));

  static final TextInputFormatter positiveNumberFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;

      if (text.isEmpty || RegExp(r'^\d+(\.\d*)?$').hasMatch(text)) {
        return newValue;
      }

      return oldValue;
    }
  );

  static final TextInputFormatter signedNumberFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;

        if (text.isEmpty || text == '-' || RegExp(r'^-?\d+(\.\d*)?$').hasMatch(text)) {
          return newValue;
        }

        return oldValue;
      });

  static bool isValidUsername(String value) => usernamePattern.hasMatch(value);
  static bool isValidPositiveNumber(String value) => positiveNumberPattern.hasMatch(value);
  static bool isValidSignedNumber(String value) => negativeNumberPattern.hasMatch(value);

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
