import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/printer_service.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:printing/printing.dart';

import '../../../../core/app/consts.dart';
import '../../../../inject_container.dart';

class ConfigPrinterDialog extends StatefulWidget {


  ConfigPrinterDialog({super.key});

  @override
  State<ConfigPrinterDialog> createState() => _ConfigPrinterDialogState();
}

class _ConfigPrinterDialogState extends State<ConfigPrinterDialog> {
  final TextEditingController nameCtrl = TextEditingController();
  final GlobalKey<FormState> form = GlobalKey<FormState>();


  late Future<({Printer? printer, List<dynamic> printers})> _loadPrinterData;

  @override
  void initState() {
    super.initState();
    PrinterService printerService = locator();
    _loadPrinterData = printerService.loadData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    PrinterService printerService = locator();

    return Dialog(
      child: Container(
        width: 350,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              spacing: 25,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titulo
                Flex(
                  direction: Axis.vertical,
                  spacing: 10,
                  children: [
                    //* Titulo
                    Text(
                      "Configuración de impresora",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    //* Description
                  ],
                ),

                // Lista de impresoras
                FutureBuilder(
                  future: _loadPrinterData,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return IsselShimmer(width: double.infinity, height: 50);
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData) {
                      return IsselPill(text: "No hay impresoras disponibles", height: 50,);
                    }

                    final data = snapshot.data!;

                    return IsselDropdown(
                      items: data.printers.map((printer) => DropdownMenuItem(
                        value: printer,
                        child: Text(printer.name),
                      )).toList(),
                      value: printerService.selectedPrinter ?? data.printer,
                      color: colorScheme.surfaceContainer,
                      hintText: "Selecciona una impresora",
                      onChanged: (p0) async {
                        await printerService.setPrinter(p0 as Printer);
                        setState(() {});
                      },
                    );

                  },
                ),

                // Divisor
                Divider(color: colorScheme.outline,),
                //* Action Boxes
                IsselButton(
                  text: "Volver",
                  onTap: () {

                    if (!form.currentState!.validate()) {
                      return ;
                    }

                    Navigator.pop(context, nameCtrl.text);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
