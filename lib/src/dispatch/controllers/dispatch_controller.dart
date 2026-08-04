import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/widgets/config_garza_container.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/dispatch/data/dispatch_sessions_api.dart';
import 'package:frontend_garzas/src/dispatch/data/pending_dispatches_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_validate_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/pending_dispatch_entity.dart';

import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';

class DispatchController extends ChangeNotifier {
  SalesApi salesApi;
  GarzasApi garzasApi;
  DispatchSessionsApi dispatchSessionsApi;
  PendingDispatchesApi pendingDispatchesApi;

  DispatchController({
    required this.salesApi,
    required this.garzasApi,
    required this.dispatchSessionsApi,
    required this.pendingDispatchesApi,
  });

  DispatchValidateEntity? dispatchValidate;
  PendingDispatchEntity? selectedPendingDispatch;
  List<ConfigGarzaEntity> availableGarzas = [];
  ConfigGarzaEntity? selectedGarza;
  String? customerEmployeeName;
  String? pendingPlateOrUnitReference;
  WaterType? pendingWaterType;
  UnitOfMeasurement? pendingUnitOfMeasurement;
  double? pendingQuantity;

  DispatchSessionEntity? activeSession;
  GarzaRuntimeEntity? selectedRuntimeGarza;
  List<GarzaRuntimeEntity> runtimeGarzas = [];
  String? runtimeMessage;

  StreamSubscription<GarzaRuntimeResponseEntity>? _runtimeSubscription;
  bool _runtimeStreamEnabled = false;
  bool _runtimeReconnectScheduled = false;
  bool _hasReceivedRuntimeSnapshot = false;
  bool _isRefreshingReleasedSession = false;
  bool _selectedRuntimeGarzaStartedOccupied = false;
  bool selectedRuntimeGarzaWasReleased = false;
  final Map<int, Set<String>> _activeAlarmsByGarza = {};
  final Map<int, _DispatchTimerState> _dispatchTimers = {};

  Duration get dispatchElapsed {
    final sessionId = activeSession?.id;
    if (sessionId == null) return Duration.zero;
    return _dispatchTimers[sessionId]?.elapsed ?? Duration.zero;
  }

  List<GarzaRuntimeEntity> get busyGarzas =>
      runtimeGarzas.where(_isRuntimeGarzaOccupied).toList();

  int get busyGarzasCount => busyGarzas.length;

  List<GarzaRuntimeEntity> get alarmGarzas => runtimeGarzas
      .where(
        (garza) => garza.hasActiveAlarms && !_isRuntimeGarzaOccupied(garza),
      )
      .toList();

  int get runtimePanelGarzasCount => busyGarzasCount + alarmGarzas.length;

  bool get hasRuntimeWarning => runtimeMessage?.trim().isNotEmpty ?? false;

  bool get dispatchHasClient {
    final commercialName = dispatchValidate?.commercialName?.trim();
    return commercialName != null && commercialName.isNotEmpty;
  }

  bool get hasCustomerEmployeeName {
    final name = customerEmployeeName?.trim();
    return name != null && name.isNotEmpty;
  }

  bool get isPendingDispatchFlow =>
      selectedPendingDispatch != null || pendingWaterType != null;

  WaterType? get activeWaterType =>
      selectedPendingDispatch?.waterType ??
      pendingWaterType ??
      dispatchValidate?.waterType;

  UnitOfMeasurement? get activeUnitOfMeasurement =>
      selectedPendingDispatch?.unitOfMeasurement ??
      pendingUnitOfMeasurement ??
      dispatchValidate?.unitOfMeasurement;

  double get activeQuantity =>
      selectedPendingDispatch?.quantity ??
      pendingQuantity ??
      dispatchValidate?.quantity ??
      0;

  double get activeDispensedQuantity {
    final pendingDispatch = selectedPendingDispatch;
    if (pendingDispatch != null) {
      return pendingDispatch.dispensedVolume;
    }

    final unit = dispatchValidate!.unitOfMeasurement;
    return _litersToUnit(dispatchValidate!.dispatchedLiters, unit);
  }

  String get activeGarzaTitle {
    final pendingDispatch = selectedPendingDispatch;
    if (pendingDispatch != null) {
      return 'Garza ${pendingDispatch.garzaNumber}';
    }

    return selectedGarza?.title ?? '-';
  }

  int? get activeGarzaNumber =>
      selectedPendingDispatch?.garzaNumber ?? selectedGarza?.number;

  void setCustomerEmployeeName(String? value) {
    final name = value?.trim();
    customerEmployeeName = name == null || name.isEmpty ? null : name;
    notifyListeners();
  }

  void preparePendingDispatch({
    String? customerEmployeeName,
    required String plateOrUnitReference,
    required WaterType waterType,
    required UnitOfMeasurement unitOfMeasurement,
  }) {
    dispatchValidate = null;
    selectedPendingDispatch = null;
    selectedGarza = null;
    final employeeName = customerEmployeeName?.trim();
    this.customerEmployeeName = employeeName == null || employeeName.isEmpty
        ? null
        : employeeName;
    pendingPlateOrUnitReference = plateOrUnitReference.trim();
    pendingWaterType = waterType;
    pendingUnitOfMeasurement = unitOfMeasurement;
    pendingQuantity = null;
    notifyListeners();
  }

  void setPendingDispatchLimitQuantity(double? quantity) {
    pendingQuantity = quantity;
    notifyListeners();
  }

  void clearPendingDispatchFlow() {
    selectedPendingDispatch = null;
    pendingPlateOrUnitReference = null;
    pendingWaterType = null;
    pendingUnitOfMeasurement = null;
    pendingQuantity = null;
  }

  void selectPendingDispatch(PendingDispatchEntity pendingDispatch) {
    dispatchValidate = null;
    selectedPendingDispatch = pendingDispatch;
    selectedGarza = null;
    customerEmployeeName = pendingDispatch.customerEmployeeName;
    pendingPlateOrUnitReference = pendingDispatch.plateOrUnitReference;
    pendingWaterType = pendingDispatch.waterType;
    pendingUnitOfMeasurement = pendingDispatch.unitOfMeasurement;
    pendingQuantity = pendingDispatch.quantity;
    notifyListeners();
  }

  Future<CtrlResponse<List<PendingDispatchEntity>>>
  listPendingDispatches() async {
    try {
      final pendingDispatches = await pendingDispatchesApi
          .listPendingDispatches(status: 'pending_dispatch');
      return CtrlResponse(success: true, element: pendingDispatches);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<PendingDispatchEntity>> cancelPendingDispatch(
    int id,
  ) async {
    try {
      final pendingDispatch = await pendingDispatchesApi.cancelPendingDispatch(
        id,
      );
      return CtrlResponse(success: true, element: pendingDispatch);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<PendingDispatchEntity>>
  createSelectedPendingDispatch() async {
    final existingPendingDispatch = selectedPendingDispatch;
    if (existingPendingDispatch != null) {
      return CtrlResponse(success: true, element: existingPendingDispatch);
    }

    final garza = selectedGarza;
    final plateOrUnitReference = pendingPlateOrUnitReference;
    final unitOfMeasurement = pendingUnitOfMeasurement;
    final quantity = pendingQuantity;

    if (garza == null ||
        plateOrUnitReference == null ||
        unitOfMeasurement == null) {
      return CtrlResponse(
        success: false,
        message: 'Faltan datos para crear el despacho pendiente',
      );
    }

    try {
      selectedPendingDispatch = await pendingDispatchesApi
          .createPendingDispatch(
            plateOrUnitReference: plateOrUnitReference,
            garzaNumber: garza.number,
            unitOfMeasurement: unitOfMeasurement,
            quantity: quantity,
            customerEmployeeName: customerEmployeeName,
          );
      pendingWaterType = selectedPendingDispatch!.waterType;
      pendingUnitOfMeasurement = selectedPendingDispatch!.unitOfMeasurement;
      pendingQuantity = selectedPendingDispatch!.quantity;
      notifyListeners();
      return CtrlResponse(success: true, element: selectedPendingDispatch);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  bool isGarzaOccupied(int garzaNumber) {
    final runtimeGarza = getRuntimeGarza(garzaNumber);
    if (runtimeGarza == null) return false;
    return _isRuntimeGarzaOccupied(runtimeGarza);
  }

  bool hasGarzaActiveAlarms(int garzaNumber) {
    return getRuntimeGarza(garzaNumber)?.hasActiveAlarms ?? false;
  }

  List<String> getGarzaAlarmDisplayNames(int garzaNumber) {
    return getRuntimeGarza(garzaNumber)?.activeAlarmDisplayNames ?? [];
  }

  GarzaRuntimeEntity? getRuntimeGarza(int garzaNumber) {
    for (final garza in runtimeGarzas) {
      if (garza.garzaNumber == garzaNumber) return garza;
    }
    return null;
  }

  bool _isRuntimeGarzaOccupied(GarzaRuntimeEntity garza) {
    return garza.isBusy && garza.activeSessionId != null;
  }

  void syncRuntimeStream({required bool shouldRun}) {
    if (shouldRun) {
      if (_runtimeStreamEnabled) return;
      _runtimeStreamEnabled = true;
      _startRuntimeStream();
      return;
    }

    if (!_runtimeStreamEnabled && _runtimeSubscription == null) return;
    _runtimeStreamEnabled = false;
    _stopRuntimeStream();
  }

  void selectRuntimeGarza(GarzaRuntimeEntity garza) {
    activeSession = null;
    selectedRuntimeGarza = garza;
    _selectedRuntimeGarzaStartedOccupied = _isRuntimeGarzaOccupied(garza);
    selectedRuntimeGarzaWasReleased = false;
    notifyListeners();
  }

  Future<CtrlResponse<DispatchSessionEntity>> createDispatchSession() async {
    try {
      final pendingDispatch = selectedPendingDispatch;
      final session = pendingDispatch == null
          ? await dispatchSessionsApi.createSession(
              dispatchCode: dispatchValidate!.dispatchCode,
              garzaNumber: selectedGarza!.number,
              customerEmployeeName: customerEmployeeName,
            )
          : await dispatchSessionsApi.createSession(
              pendingDispatchId: pendingDispatch.id,
              garzaNumber: pendingDispatch.garzaNumber,
            );

      selectedRuntimeGarza = null;
      _selectedRuntimeGarzaStartedOccupied = false;
      selectedRuntimeGarzaWasReleased = false;
      activeSession = await dispatchSessionsApi.getSession(session.id);
      _syncDispatchTimer(activeSession!);
      notifyListeners();
      return CtrlResponse(success: true, element: activeSession);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<DispatchSessionEntity>> loadRuntimeSession(
    int sessionId,
  ) async {
    try {
      final session = await dispatchSessionsApi.getSession(sessionId);
      activeSession = session;
      _syncDispatchTimer(session);
      notifyListeners();
      return CtrlResponse(success: true, element: session);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<DispatchSessionEntity>> startActiveSession() {
    return _runSessionAction(
      action: dispatchSessionsApi.startSession,
      missingMessage: 'No hay una sesion de despacho seleccionada',
    );
  }

  Future<CtrlResponse<DispatchSessionEntity>> pauseActiveSession() {
    return _runSessionAction(
      action: dispatchSessionsApi.pauseSession,
      missingMessage: 'No hay una sesion de despacho seleccionada',
    );
  }

  Future<CtrlResponse<DispatchSessionEntity>> resumeActiveSession() {
    return _runSessionAction(
      action: dispatchSessionsApi.resumeSession,
      missingMessage: 'No hay una sesion de despacho seleccionada',
    );
  }

  Future<CtrlResponse<DispatchSessionEntity>> completeActiveSession() {
    return _runSessionAction(
      action: dispatchSessionsApi.completeSession,
      missingMessage: 'No hay una sesion de despacho seleccionada',
    );
  }

  Future<CtrlResponse<DispatchSessionEntity>> _runSessionAction({
    required Future<DispatchSessionEntity> Function(int sessionId) action,
    required String missingMessage,
  }) async {
    final sessionId =
        activeSession?.id ?? selectedRuntimeGarza?.activeSessionId;
    if (sessionId == null) {
      return CtrlResponse(success: false, message: missingMessage);
    }

    try {
      final session = await action(sessionId);
      activeSession = session;
      _syncDispatchTimer(session);
      notifyListeners();
      return CtrlResponse(success: true, element: session);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  void _startRuntimeStream() {
    if (_runtimeSubscription != null || !_runtimeStreamEnabled) return;

    _runtimeSubscription = dispatchSessionsApi.streamGarzaRuntime().listen(
      (snapshot) {
        _handleRuntimeSnapshot(snapshot);
      },
      onError: (_) {
        _runtimeSubscription = null;
        _scheduleRuntimeReconnect();
      },
      onDone: () {
        _runtimeSubscription = null;
        _scheduleRuntimeReconnect();
      },
      cancelOnError: true,
    );
  }

  void _stopRuntimeStream() {
    _runtimeSubscription?.cancel();
    _runtimeSubscription = null;
    _runtimeReconnectScheduled = false;
    _hasReceivedRuntimeSnapshot = false;
    runtimeGarzas = [];
    runtimeMessage = null;
    _activeAlarmsByGarza.clear();
    _selectedRuntimeGarzaStartedOccupied = false;
    selectedRuntimeGarzaWasReleased = false;
    notifyListeners();
  }

  void _scheduleRuntimeReconnect() {
    if (!_runtimeStreamEnabled || _runtimeReconnectScheduled) return;

    _runtimeReconnectScheduled = true;
    Timer(const Duration(seconds: 5), () {
      _runtimeReconnectScheduled = false;
      _startRuntimeStream();
    });
  }

  void _handleRuntimeSnapshot(GarzaRuntimeResponseEntity snapshot) {
    runtimeGarzas = snapshot.garzas;
    runtimeMessage = snapshot.message;
    _syncActiveSessionFromRuntime(snapshot.garzas);
    _notifyNewAlarms(snapshot.garzas);
    _hasReceivedRuntimeSnapshot = true;
    notifyListeners();
  }

  void _syncActiveSessionFromRuntime(List<GarzaRuntimeEntity> garzas) {
    final session = activeSession;
    if (session == null) return;
    if (session.state == DispatchState.completed ||
        session.state == DispatchState.interrupted) {
      return;
    }

    final currentGarza = _findRuntimeGarzaByNumber(garzas, session.garzaNumber);
    if (currentGarza != null &&
        _selectedRuntimeGarzaStartedOccupied &&
        !currentGarza.isBusy &&
        currentGarza.activeSessionId == null) {
      selectedRuntimeGarza = currentGarza;
      selectedRuntimeGarzaWasReleased = true;
      _syncDispatchTimer(
        session.copyWith(
          state: currentGarza.currentState ?? DispatchState.completed,
        ),
        backendElapsedMs: currentGarza.dispatchElapsedMs,
        isBusy: false,
      );
      _refreshActiveSessionFromServer(session.id);
      return;
    }

    GarzaRuntimeEntity? runtimeGarza;
    for (final garza in garzas) {
      if (_runtimeGarzaMatchesSession(garza, session)) {
        runtimeGarza = garza;
        break;
      }
    }

    if (runtimeGarza == null) {
      _refreshActiveSessionFromServer(session.id);
      return;
    }

    selectedRuntimeGarza = runtimeGarza;
    selectedRuntimeGarzaWasReleased = false;
    if (_isRuntimeGarzaOccupied(runtimeGarza)) {
      _selectedRuntimeGarzaStartedOccupied = true;
    }
    activeSession = session.copyWith(
      state: runtimeGarza.currentState,
      unitOfMeasurement: runtimeGarza.unitOfMeasurement,
      authorizedVolume: runtimeGarza.authorizedVolume,
      dispensedVolume: runtimeGarza.dispensedVolume,
      updatedAt: runtimeGarza.updatedAt,
    );
    _syncDispatchTimer(
      activeSession!,
      backendElapsedMs: runtimeGarza.dispatchElapsedMs,
      isBusy: runtimeGarza.isBusy,
    );
  }

  GarzaRuntimeEntity? _findRuntimeGarzaByNumber(
    List<GarzaRuntimeEntity> garzas,
    int garzaNumber,
  ) {
    for (final garza in garzas) {
      if (garza.garzaNumber == garzaNumber) return garza;
    }
    return null;
  }

  bool _runtimeGarzaMatchesSession(
    GarzaRuntimeEntity garza,
    DispatchSessionEntity session,
  ) {
    if (garza.activeSessionId == session.id) return true;
    if (garza.garzaNumber != session.garzaNumber) return false;

    final sameDispatchCode = garza.dispatchCode == session.dispatchCode;
    final sameSaleFolio = garza.saleFolio == session.saleFolio;
    final closedByPlc =
        garza.currentState == DispatchState.completed ||
        garza.currentState == DispatchState.interrupted;

    return sameDispatchCode || sameSaleFolio || closedByPlc;
  }

  Future<void> _refreshActiveSessionFromServer(int sessionId) async {
    if (_isRefreshingReleasedSession) return;

    _isRefreshingReleasedSession = true;
    try {
      final refreshedSession = await dispatchSessionsApi.getSession(sessionId);
      if (activeSession?.id != sessionId) return;

      activeSession = refreshedSession;
      _syncDispatchTimer(refreshedSession);
      if (refreshedSession.state == DispatchState.completed ||
          refreshedSession.state == DispatchState.interrupted) {
        selectedRuntimeGarza = null;
      }
      notifyListeners();
    } on AppException {
      // The runtime stream will keep trying on the next snapshot.
    } finally {
      _isRefreshingReleasedSession = false;
    }
  }

  void _notifyNewAlarms(List<GarzaRuntimeEntity> garzas) {
    final toastService = locator<ToastService>();

    for (final garza in garzas) {
      final previousAlarms = _activeAlarmsByGarza[garza.garzaNumber] ?? {};
      final currentAlarms = garza.activeAlarmNames.toSet();

      if (_hasReceivedRuntimeSnapshot) {
        final newAlarms = currentAlarms.difference(previousAlarms);
        for (final alarm in newAlarms) {
          toastService.error(
            'Alarma en garza ${garza.garzaNumber}: ${GarzaRuntimeEntity.alarmDisplayName(alarm)}',
          );
        }
      }

      _activeAlarmsByGarza[garza.garzaNumber] = currentAlarms;
    }
  }

  Future<CtrlResponse> validateBarcode(String barcode) async {
    try {
      DispatchValidateEntity validate = await salesApi.validateDispatch(
        barcode,
      );
      clearPendingDispatchFlow();
      dispatchValidate = validate;
      selectedGarza = null;
      customerEmployeeName = null;
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getAvailableGarzas() async {
    try {
      List<ConfigGarzaEntity> tempGarzas = await garzasApi.listGarzas(
        waterType: activeWaterType!,
      );
      availableGarzas = tempGarzas;
      notifyListeners();
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse<SaleEntity>> dispatch() async {
    try {
      final sale = await salesApi.dispatch(
        dispatchValidate!.dispatchCode,
        selectedGarza!.number,
      );

      return CtrlResponse(success: true, element: sale);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  double _litersToUnit(double liters, UnitOfMeasurement unit) {
    switch (unit) {
      case UnitOfMeasurement.liters:
        return liters;
      case UnitOfMeasurement.gallons:
        return liters / 3.785411784;
    }
  }

  void _syncDispatchTimer(
    DispatchSessionEntity session, {
    int? backendElapsedMs,
    bool? isBusy,
  }) {
    final timer = _dispatchTimers.putIfAbsent(
      session.id,
      _DispatchTimerState.new,
    );

    final synchronizedElapsedMs = backendElapsedMs ?? session.dispatchElapsedMs;
    if (synchronizedElapsedMs != null) {
      timer.synchronize(Duration(milliseconds: synchronizedElapsedMs));
    }

    final isFinished =
        session.state == DispatchState.completed ||
        session.state == DispatchState.interrupted;
    final shouldRun =
        !isFinished &&
        isBusy != false &&
        (session.state == DispatchState.dispensing ||
            (session.mode == DispatchMode.manual &&
                session.state != DispatchState.paused));

    if (shouldRun) {
      timer.start();
    } else {
      timer.stop();
    }
  }

  @override
  void dispose() {
    _runtimeSubscription?.cancel();
    for (final timer in _dispatchTimers.values) {
      timer.stop();
    }
    _dispatchTimers.clear();
    super.dispose();
  }
}

class _DispatchTimerState {
  Duration _synchronizedElapsed = Duration.zero;
  final Stopwatch _sinceSynchronization = Stopwatch();

  Duration get elapsed => _synchronizedElapsed + _sinceSynchronization.elapsed;

  void synchronize(Duration elapsed) {
    _synchronizedElapsed = elapsed.isNegative ? Duration.zero : elapsed;
    _sinceSynchronization
      ..stop()
      ..reset();
  }

  void start() => _sinceSynchronization.start();

  void stop() => _sinceSynchronization.stop();
}
