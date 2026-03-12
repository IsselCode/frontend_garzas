import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _PRINTER = "PRINTER";

class PrinterService {

  SharedPreferences sharedPreferences;

  PrinterService({
    required this.sharedPreferences,
  });

  Printer? selectedPrinter;

  Future<({Printer? printer, List<dynamic> printers})> loadData() async {
    final printer = await getPrinter();
    final printers = await listPrinters();
    return (printer: printer, printers: printers);
  }

  Future<List<Printer>> listPrinters() async {

    List<Printer> printers = await Printing.listPrinters();

    if (selectedPrinter == null) return printers;

    int index = printers.indexWhere((element) => element.url == selectedPrinter!.url,);
    printers[index] = selectedPrinter!;
    return printers;

  }

  Future<Printer?> getPrinter() async {

    String? prefPrinter = sharedPreferences.getString(_PRINTER);
    if (prefPrinter == null) return null;

    List<Printer> printers = await Printing.listPrinters();
    for (final printer in printers) {
      if (printer.url == prefPrinter) {
        selectedPrinter = printer;
        return printer;
      }
    }
    return null;
  }

  Future<void> setPrinter(Printer printer) async {

    // Guardamos impresora en preferencias
    bool response = await sharedPreferences.setString(_PRINTER, printer.url);

    // Manejamos posible error
    if (!response) {
      throw AppException(message: "No se pudo guardar la impresora");
    }

    // Asignamos impresora
    selectedPrinter = printer;

  }

}
