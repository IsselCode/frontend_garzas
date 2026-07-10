import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

import '../../../../inject_container.dart';

class ClientEmployeeBarcodeDialog extends StatefulWidget {
  const ClientEmployeeBarcodeDialog({super.key});

  @override
  State<ClientEmployeeBarcodeDialog> createState() =>
      _ClientEmployeeBarcodeDialogState();
}

class _ClientEmployeeBarcodeDialogState
    extends State<ClientEmployeeBarcodeDialog> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController employeeNameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Codigo de empleado",
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Form(
              key: formKey,
              child: IsselTextFormField(
                controller: employeeNameCtrl,
                hintText: "Nombre del empleado",
                prefixIcon: Icons.badge_outlined,
                fillColor: theme.scaffoldBackgroundColor,
                validator: (value) {
                  final text = value?.trim() ?? "";
                  if (text.isEmpty) return "Campo requerido";
                  return null;
                },
              ),
            ),
            IsselButton(text: "Guardar codigo", height: 50, onTap: saveBarcode),
            IsselButton(
              text: "Cancelar",
              height: 50,
              color: Colors.transparent,
              textColor: colorScheme.onSurface,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveBarcode() async {
    if (!formKey.currentState!.validate()) return;

    final toastService = locator<ToastService>();
    final employeeName = employeeNameCtrl.text.trim();

    try {
      final savedPath = await _saveBarcode(employeeName);
      if (savedPath == null) return;

      toastService.success("Codigo guardado en $savedPath");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      toastService.error("No se pudo guardar el codigo de barras");
    }
  }

  Future<String?> _saveBarcode(String employeeName) async {
    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: const [
        XTypeGroup(label: "PNG", extensions: ["png"]),
      ],
      suggestedName: "${_safeFileName(employeeName)}.png",
      confirmButtonText: "Guardar",
      canCreateDirectories: true,
    );

    if (saveLocation == null) return null;
    final path = _ensurePngExtension(saveLocation.path);
    final pngBytes = await _buildBarcodePng(employeeName);

    await File(path).writeAsBytes(pngBytes, flush: true);
    return path;
  }

  Future<Uint8List> _buildBarcodePng(String barcodeData) async {
    const width = 1260.0;
    const height = 320.0;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = Colors.black;
    final elements = Barcode.code128().make(
      barcodeData,
      width: width,
      height: height,
      drawText: false,
    );

    for (final element in elements) {
      if (element is BarcodeBar) {
        if (!element.black) continue;

        canvas.drawRect(
          ui.Rect.fromLTWH(
            element.left,
            element.top,
            element.width,
            element.height,
          ),
          paint,
        );
        continue;
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();

    if (byteData == null) {
      throw Exception("No se pudo generar el PNG");
    }

    return byteData.buffer.asUint8List();
  }

  String _ensurePngExtension(String path) {
    if (path.toLowerCase().endsWith(".png")) return path;
    return "$path.png";
  }

  String _safeFileName(String value) {
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');

    if (normalized.isEmpty) return "codigo";
    return normalized;
  }

  @override
  void dispose() {
    employeeNameCtrl.dispose();
    super.dispose();
  }
}
