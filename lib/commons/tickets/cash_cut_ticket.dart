import 'dart:typed_data';

import 'package:frontend_garzas/src/auth/models/auth_session.dart';
import 'package:frontend_garzas/src/sales/clean/entities/closed_cut_summary_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const PdfPageFormat cashCutTicketPageFormat = PdfPageFormat(
  72 * PdfPageFormat.mm,
  double.infinity,
  marginLeft: 4 * PdfPageFormat.mm,
  marginRight: 4 * PdfPageFormat.mm,
  marginTop: 6 * PdfPageFormat.mm,
  marginBottom: 6 * PdfPageFormat.mm,
);

class CashCutTicketEntity {
  final ClosedCutSummaryEntity summary;
  final AuthSession user;
  final double declaredCashTotal;
  final double declaredCardTotal;
  final DateTime closedAt;

  const CashCutTicketEntity({
    required this.summary,
    required this.user,
    required this.declaredCashTotal,
    required this.declaredCardTotal,
    required this.closedAt,
  });
}

Future<Uint8List> cashCutTicketPdf(
  CashCutTicketEntity ticket, {
  PdfPageFormat pageFormat = cashCutTicketPageFormat,
}) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final fontTitle = await PdfGoogleFonts.montserratAlternatesBlack();
  final fontText = await PdfGoogleFonts.montserratMedium();
  final fontBold = await PdfGoogleFonts.montserratBold();
  final summary = ticket.summary;
  final cashDifference = ticket.declaredCashTotal - summary.expectedCashTotal;
  final cardDifference = ticket.declaredCardTotal - summary.cardTotal;
  final totalSales =
      summary.cashTotal + summary.cardTotal + summary.creditTotal;

  String twoDigits(int value) => value.toString().padLeft(2, '0');
  String formatDate(DateTime date) =>
      '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  String formatTime(DateTime date) =>
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  String formatMoney(double amount) => '\$${amount.toStringAsFixed(2)}';
  String formatNumber(double amount) => amount.toStringAsFixed(2);

  pw.TextStyle textStyle({bool bold = false, double fontSize = 8}) {
    return pw.TextStyle(font: bold ? fontBold : fontText, fontSize: fontSize);
  }

  pw.Widget separator([String char = '=']) {
    return pw.Text(
      List.filled(38, char).join(),
      style: textStyle(bold: true, fontSize: 7),
      textAlign: pw.TextAlign.center,
    );
  }

  pw.Widget sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 4),
        separator('-'),
        pw.Text(
          title,
          style: textStyle(bold: true, fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        separator('-'),
      ],
    );
  }

  pw.Widget row(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(label, style: textStyle(bold: bold)),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              value,
              style: textStyle(bold: bold),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget saleRow(ClosedCutSaleEntity sale) {
    final quantity =
        '${formatNumber(sale.quantity)} ${sale.unitOfMeasurement.abbr}';

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  sale.folio,
                  style: textStyle(bold: true, fontSize: 7),
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Text(
                formatMoney(sale.total),
                style: textStyle(bold: true, fontSize: 7),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.Text(
            '${sale.waterType.dp} / $quantity / ${sale.paymentMethod.label}',
            style: textStyle(fontSize: 6),
          ),
        ],
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            separator(),
            pw.Text(
              'CORTE DE CAJA',
              style: pw.TextStyle(font: fontTitle, fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
            separator(),
            pw.SizedBox(height: 6),
            row('Fecha:', formatDate(ticket.closedAt), bold: true),
            row('Hora:', formatTime(ticket.closedAt), bold: true),
            row('Usuario:', ticket.user.displayName, bold: true),
            sectionTitle('RESUMEN DE VENTAS'),
            row('Notas vendidas:', '${summary.salesCount}', bold: true),
            pw.SizedBox(height: 4),
            row('Ventas en efectivo:', '${summary.cashSalesCount}'),
            row('Ventas en tarjeta:', '${summary.cardSalesCount}'),
            row('Ventas a credito:', '${summary.creditSalesCount}'),
            pw.SizedBox(height: 4),
            row(
              'Litros potable:',
              formatNumber(summary.litersSoldByWaterType.potable),
            ),
            row(
              'Litros pozo:',
              formatNumber(summary.litersSoldByWaterType.pozo),
            ),
            row(
              'Litros vendidos:',
              formatNumber(summary.totalLitersSold),
              bold: true,
            ),
            sectionTitle('TOTALES'),
            row('Efectivo:', formatMoney(summary.cashTotal), bold: true),
            row('Tarjeta:', formatMoney(summary.cardTotal), bold: true),
            row('Credito:', formatMoney(summary.creditTotal), bold: true),
            separator('-'),
            row('VENTA TOTAL:', formatMoney(totalSales), bold: true),
            sectionTitle('EFECTIVO EN CAJA'),
            row('Fondo inicial:', formatMoney(summary.openingAmount)),
            row('Ingresos:', formatMoney(summary.cashTotal)),
            separator('-'),
            row(
              'Total esperado:',
              formatMoney(summary.expectedCashTotal),
              bold: true,
            ),
            row(
              'Efectivo contado:',
              formatMoney(ticket.declaredCashTotal),
              bold: true,
            ),
            separator('-'),
            row('Diferencia:', formatMoney(cashDifference), bold: true),
            sectionTitle('TARJETA'),
            row('Total esperado:', formatMoney(summary.cardTotal), bold: true),
            row(
              'Tarjeta contada:',
              formatMoney(ticket.declaredCardTotal),
              bold: true,
            ),
            separator('-'),
            row('Diferencia:', formatMoney(cardDifference), bold: true),
            if (summary.sales.isNotEmpty) ...[
              sectionTitle('VENTAS REALIZADAS'),
              ...summary.sales.map(saleRow),
            ],
            pw.SizedBox(height: 4),
            separator(),
            pw.Text(
              'FIN DEL CORTE',
              style: textStyle(bold: true, fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
            separator(),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
