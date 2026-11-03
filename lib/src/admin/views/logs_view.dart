import 'package:frontend_garzas/commons/widgets/paged_list_panel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/services/toast_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import '../widgets/admin_date_range_fields.dart';
import 'package:frontend_garzas/src/admin/controllers/statistics_controller.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

class LogsView extends StatefulWidget {
  const LogsView({super.key});
  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  late Future<CtrlResponse> _loadLogs;
  DateTimeRange? _logsDateRange;

  @override
  void initState() {
    super.initState();
    _loadLogs = context.read<StatisticsController>().clearLogsDateRange();
  }

  @override
  Widget build(BuildContext context) {
    final statistics = context.watch<StatisticsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme.copyWith(
      labelMedium: theme.textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder(
          future: _loadLogs,
          builder: (context, snapshot) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colorScheme.surface,
              ),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 400,
                    child: AdminDateRangeFields(
                      initialRange: _logsDateRange,
                      onChanged: _applyLogsDateRange,
                    ),
                  ),
                  Expanded(
                    child: PagedListPanel(
                      state: statistics.logsPaging,
                      onPageChanged: (page) => statistics.getLogs(page: page),
                      child: IsselTableWidget(
                        header: IsselHeaderTable(
                          titleHeaders: [
                            "Tipo",
                            "Usuario",
                            "Información",
                            "Fecha",
                          ],
                        ),
                        rows: statistics.showedLogs
                            .map(
                              (log) => IsselRowTable(
                                cells: [
                                  // Empleado
                                  IsselPill(
                                    color: colorScheme.surfaceContainer,
                                    padding: EdgeInsets.zero,
                                    widget: Tooltip(
                                      message: log.tipo,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          log.tipo,
                                          style: textTheme.labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                  // Cantidades
                                  IsselPill(
                                    color: colorScheme.surfaceContainer,
                                    widget: Text(
                                      log.username,
                                      style: textTheme.labelMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                  // Información
                                  IsselPill(
                                    color: colorScheme.surfaceContainer,
                                    padding: EdgeInsets.zero,
                                    widget: Tooltip(
                                      message: log.info,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: AutoSizeText(
                                          log.info,
                                          style: textTheme.labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                  IsselPill(
                                    color: colorScheme.surfaceContainer,
                                    padding: EdgeInsets.zero,
                                    widget: Tooltip(
                                      message: DateFormat(
                                        "dd/MM/yy hh:mm:ss a",
                                      ).format(log.createdAt),
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          DateFormat(
                                            "dd/MM/yy hh:mm:ss a",
                                          ).format(log.createdAt),
                                          style: textTheme.labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _applyLogsDateRange(DateTimeRange? range) async {
    final StatisticsController statisticsController = context.read();
    final ToastService toastService = locator();
    if (range == null) {
      final cleared = await statisticsController.clearLogsDateRange();
      if (!mounted || !cleared.success) return false;
      setState(() => _logsDateRange = null);
      return true;
    }
    final CtrlResponse response = await statisticsController.getLogsByDateRange(
      startDate: range.start,
      endDate: range.end,
    );
    if (!mounted) return false;
    if (response.success) {
      toastService.success("Logs filtrados correctamente");
    } else {
      toastService.error(response.message ?? "No se pudieron filtrar los logs");
      return false;
    }
    setState(() => _logsDateRange = range);
    return true;
  }
}
