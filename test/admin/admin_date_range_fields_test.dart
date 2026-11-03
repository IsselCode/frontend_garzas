import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_garzas/src/admin/clean/dialogs/admin_date_picker_dialog.dart';
import 'package:frontend_garzas/src/admin/widgets/admin_date_range_fields.dart';

void main() {
  late List<DateTimeRange?> changes;
  var acceptChange = true;

  Future<void> mount(WidgetTester tester, {DateTimeRange? initial}) async {
    changes = [];
    acceptChange = true;
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: AdminDateRangeFields(
                initialRange: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030, 12, 31),
                onChanged: (range) async {
                  changes.add(range);
                  return acceptChange;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder field(int index) => find.byType(AdminDateFilterField).at(index);

  Future<void> selectDate(WidgetTester tester, int index, DateTime date) async {
    await tester.tap(field(index));
    await tester.pumpAndSettle();
    expect(find.byType(AdminDatePickerDialog), findsOneWidget);
    expect(find.byType(DateRangePickerDialog), findsNothing);
    tester
        .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
        .onDateChanged(date);
    await tester.pump();
    await tester.tap(find.text('Seleccionar'));
    await tester.pumpAndSettle();
  }

  testWidgets('inline dates apply immediately and clear independently', (
    tester,
  ) async {
    await mount(
      tester,
      initial: DateTimeRange(
        start: DateTime(2026, 11, 2),
        end: DateTime(2026, 11, 4),
      ),
    );
    expect(find.text('Fecha inicial'), findsOneWidget);
    expect(find.text('Fecha final'), findsOneWidget);
    expect(find.text('Aplicar'), findsNothing);

    await selectDate(tester, 0, DateTime(2026, 11, 3));
    expect(changes.single?.start, DateTime(2026, 11, 3));
    expect(changes.single?.end, DateTime(2026, 11, 4, 23, 59, 59, 999));

    await tester.tap(field(1));
    await tester.pumpAndSettle();
    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(picker.firstDate, DateTime(2026, 11, 3));
    picker.onDateChanged(DateTime(2026, 11, 5));
    await tester.pump();
    await tester.tap(find.text('Seleccionar'));
    await tester.pumpAndSettle();
    expect(changes.last?.end, DateTime(2026, 11, 5, 23, 59, 59, 999));

    await tester.tap(
      find.descendant(of: field(0), matching: find.byTooltip('Limpiar filtro')),
    );
    await tester.pumpAndSettle();
    expect(changes.last?.start, DateTime(2020));
    expect(find.text('Todas las fechas'), findsOneWidget);
    expect(find.text('05/11/2026'), findsOneWidget);

    await tester.tap(
      find.descendant(of: field(1), matching: find.byTooltip('Limpiar filtro')),
    );
    await tester.pumpAndSettle();
    expect(changes.last, isNull);
    expect(find.text('Todas las fechas'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling and failed queries preserve the displayed dates', (
    tester,
  ) async {
    await mount(
      tester,
      initial: DateTimeRange(
        start: DateTime(2026, 11, 2),
        end: DateTime(2026, 11, 4),
      ),
    );
    await tester.tap(field(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(find.text('02/11/2026'), findsOneWidget);

    acceptChange = false;
    await selectDate(tester, 0, DateTime(2026, 11, 3));
    expect(changes, hasLength(1));
    expect(find.text('02/11/2026'), findsOneWidget);
    expect(find.text('03/11/2026'), findsNothing);

    acceptChange = true;
    await selectDate(tester, 0, DateTime(2026, 11, 3));
    expect(find.text('03/11/2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a final date can be selected first without inventing a displayed initial date',
    (tester) async {
      await mount(tester);
      await selectDate(tester, 1, DateTime(2026, 11, 4));
      expect(changes.single?.start, DateTime(2020));
      expect(changes.single?.end, DateTime(2026, 11, 4, 23, 59, 59, 999));
      expect(find.text('Todas las fechas'), findsOneWidget);
      expect(find.text('04/11/2026'), findsOneWidget);
      await tester.tap(field(0));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
            .lastDate,
        DateTime(2026, 11, 4),
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(changes, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
}
