import 'package:unorm_dart/unorm_dart.dart' as unorm;

String removeAccentsKeepEnyeUtil(String text) {
  final decomposed = unorm.nfd(text);

  final cleaned = decomposed.replaceAll(RegExp(r'[\u0300\u0301\u0302\u0304-\u036f]'), '',);

  return cleaned;
}