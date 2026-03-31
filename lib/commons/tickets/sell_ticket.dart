import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:frontend_garzas/src/admin/clean/entities/general_config_entity.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SellTicketEntity {
  String folio;
  String? clientName;
  String? clientPhone;
  WaterType waterType;
  UnitOfMeasurement unitOfMeasurement;
  double quantity;
  double total;
  double amountPaid;
  double changeAmount;
  String dispatchCode;
  DateTime createdAt;

  SellTicketEntity({
    required this.folio,
    required this.clientName,
    required this.clientPhone,
    required this.waterType,
    required this.unitOfMeasurement,
    required this.quantity,
    required this.total,
    required this.amountPaid,
    required this.changeAmount,
    required this.dispatchCode,
    required this.createdAt,
  });
}

Future<Uint8List> sellTicketPdf(
  GeneralConfigEntity generalConfigEntity,
  SellTicketEntity sellTicketEntity,
) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final fontTitle = await PdfGoogleFonts.montserratAlternatesBlackItalic();
  final fontText = await PdfGoogleFonts.montserratMedium();

  final businessName = generalConfigEntity.businessName.trim();
  final businessAddress = generalConfigEntity.businessAddress.trim();
  final extraInfo1 = generalConfigEntity.extraInfo1.trim();
  final extraInfo2 = generalConfigEntity.extraInfo2.trim();
  final createdAt = sellTicketEntity.createdAt;
  final barcodeData = sellTicketEntity.dispatchCode;
  final clientName = (sellTicketEntity.clientName ?? '').trim();
  final clientPhone = (sellTicketEntity.clientPhone ?? '').trim();
  final quantityText = '${sellTicketEntity.quantity.toStringAsFixed(2)} ${sellTicketEntity.unitOfMeasurement.abbr}';

  String twoDigits(int value) => value.toString().padLeft(2, '0');
  String formatDate(DateTime date) =>
      '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  String formatTime(DateTime date) =>
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  String formatMoney(double amount) => '\$${amount.toStringAsFixed(2)}';

  pw.Widget dataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: fontText, fontSize: 8),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              value,
              style: pw.TextStyle(font: fontText, fontSize: 8),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(12),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: <pw.Widget>[
            pw.Text(
              businessName.isEmpty ? 'Ticket de venta' : businessName,
              style: pw.TextStyle(
                font: fontTitle,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
            if (businessAddress.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                businessAddress,
                style: pw.TextStyle(font: fontText, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ],
            pw.SizedBox(height: 4),
            pw.Text(
              '${formatDate(createdAt)} ${formatTime(createdAt)}',
              style: pw.TextStyle(font: fontText, fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Folio ${sellTicketEntity.folio}',
              style: pw.TextStyle(font: fontText, fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.Text(
              'VENTA DE AGUA',
              style: pw.TextStyle(font: fontTitle, fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 6),
            dataRow('Cliente', clientName.isEmpty ? 'Publico general' : clientName),
            dataRow('Telefono', clientPhone.isEmpty ? 'N/D' : clientPhone),
            dataRow('Tipo de agua', sellTicketEntity.waterType.dp),
            dataRow('Cantidad', quantityText),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 4),
            dataRow('Total', formatMoney(sellTicketEntity.total)),
            dataRow('Pago', formatMoney(sellTicketEntity.amountPaid)),
            dataRow('Cambio', formatMoney(sellTicketEntity.changeAmount)),
            pw.SizedBox(height: 14),
            pw.BarcodeWidget(
              barcode: Barcode.code128(),
              data: barcodeData,
              width: double.infinity,
              height: 42,
              drawText: true,
              textPadding: 4,
              textStyle: pw.TextStyle(
                font: fontText,
                fontSize: 8,
              ),
            ),
            pw.Divider(),
            if (extraInfo1.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                extraInfo1,
                style: pw.TextStyle(font: fontText, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ],
            if (extraInfo2.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                extraInfo2,
                style: pw.TextStyle(font: fontText, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ],
        );
      },
    ),
  );

  return pdf.save();
}
