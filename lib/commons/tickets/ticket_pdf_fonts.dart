import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class TicketPdfFonts {
  static final Future<pw.Font> sellTitle = _load(
    'assets/fonts/MontserratAlternates-BlackItalic.ttf',
  );
  static final Future<pw.Font> cashCutTitle = _load(
    'assets/fonts/MontserratAlternates-Black.ttf',
  );
  static final Future<pw.Font> regular = _load(
    'assets/fonts/Montserrat-Medium.ttf',
  );
  static final Future<pw.Font> bold = _load('assets/fonts/Montserrat-Bold.ttf');

  static Future<pw.Font> _load(String assetPath) async {
    final fontData = await rootBundle.load(assetPath);
    return pw.Font.ttf(fontData);
  }
}
