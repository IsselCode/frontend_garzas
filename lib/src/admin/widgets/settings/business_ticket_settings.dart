import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:printing/printing.dart';

import '../../../../commons/tickets/sell_ticket.dart';
import '../../clean/entities/general_config_entity.dart';
import '../../clean/enums/enums.dart';
import '../../clean/widgets/config_garza_container.dart';

class BusinessTicketSettings extends StatelessWidget {
  const BusinessTicketSettings({
    super.key,
    required this.formKey,
    required this.businessName,
    required this.businessAddress,
    required this.extraInfo1,
    required this.extraInfo2,
    required this.printQuantity,
    required this.onPrintQuantityChanged,
    required this.previewConfig,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController businessName,
      businessAddress,
      extraInfo1,
      extraInfo2;
  final int printQuantity;
  final ValueChanged<double> onPrintQuantityChanged;
  final GeneralConfigEntity previewConfig;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final form = Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IsselStepperField(
              title: 'Impresiones',
              initValue: printQuantity.toDouble(),
              minValue: 0,
              maxValue: 10,
              onChanged: onPrintQuantityChanged,
              backColor: colors.surfaceContainer,
              counterColor: colors.surface,
            ),
            const SizedBox(height: 16),
            Text('Nombre de la empresa', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            IsselTextFormField(
              controller: businessName,
              hintText: 'PABN PURIFICADORA',
              prefixIcon: Icons.title_outlined,
              height: 48,
              fillColor: colors.surfaceContainer,
            ),
            const SizedBox(height: 14),
            Text('Dirección de la empresa', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            IsselTextFormField(
              controller: businessAddress,
              hintText: 'Monzón 81000',
              prefixIcon: Icons.directions_outlined,
              height: 48,
              fillColor: colors.surfaceContainer,
            ),
            const SizedBox(height: 14),
            Text('Información adicional', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            IsselTextFormField(
              controller: extraInfo1,
              hintText: 'Gracias por su compra.',
              prefixIcon: Icons.info_outline,
              height: 48,
              fillColor: colors.surfaceContainer,
            ),
            const SizedBox(height: 10),
            IsselTextFormField(
              controller: extraInfo2,
              hintText: '¡Vuelva Pronto!',
              prefixIcon: Icons.info_outline,
              height: 48,
              fillColor: colors.surfaceContainer,
            ),
          ],
        ),
      ),
    );
    final preview = BusinessTicketPreview(config: previewConfig);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return SingleChildScrollView(
            child: Column(
              children: [
                form,
                const SizedBox(height: 24),
                SizedBox(height: 540, child: preview),
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: form),
            const SizedBox(width: 24),
            Expanded(child: preview),
          ],
        );
      },
    );
  }
}

class BusinessTicketPreview extends StatelessWidget {
  const BusinessTicketPreview({super.key, required this.config});
  final GeneralConfigEntity config;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: PdfPreview.builder(
      useActions: false,
      pdfPreviewPageDecoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [],
      ),
      scrollViewDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      pagesBuilder: (context, pages) {
        if (pages.isEmpty) {
          return Center(child: IsselCircularProgressIndicator());
        }
        final page = pages.first;
        return LayoutBuilder(
          builder: (context, constraints) => Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth * .95,
                child: AspectRatio(
                  aspectRatio: page.aspectRatio,
                  // PDF rasters can have a transparent paper background.
                  // The custom pagesBuilder bypasses PdfPreview's decoration.
                  child: ColoredBox(
                    color: Colors.white,
                    child: Image(image: page.image, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      build: (format) => sellTicketPdf(
        config,
        SellTicketEntity(
          ticketNumber: 1,
          copyNumber: 1,
          folio: '1839174451',
          dispatchCode: '16383917445163345',
          commercialName: 'ACME S.A.',
          total: 500,
          paymentMethod: PaymentMethod.cash,
          amountPaid: 600,
          changeAmount: 100,
          waterType: WaterType.potable,
          unitOfMeasurement: UnitOfMeasurement.gallons,
          quantity: 125,
          createdAt: DateTime.now(),
          sellerName: 'Prueba',
        ),
      ),
    ),
  );
}
