import '../../../commons/paged_list_state.dart';
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

class LastDispatchSnapshot {
  final DispatchSessionEntity session;
  final GarzaRuntimeEntity? runtimeGarza;

  const LastDispatchSnapshot({
    required this.session,
    required this.runtimeGarza,
  });

  int? get dispatchElapsedMs =>
      session.dispatchElapsedMs ?? runtimeGarza?.dispatchElapsedMs;
}

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
  }) {
    pendingPaging = PagedListState(onChanged: notifyListeners);
  }
  late final PagedListState<PendingDispatchEntity> pendingPaging;

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
  Timer? _runtimeReconnectTimer;
  Timer? _runtimeWatchdog;
  int _runtimeGeneration = 0;
  int _selectionRevision = 0;
  int _sessionLoadRevision = 0;
  bool _runtimeStreamInterrupted = false;
  bool _runtimeStreamEnabled = false;
  bool _runtimeReconnectScheduled = false;
  bool _hasReceivedRuntimeSnapshot = false;
  final Set<int> _refreshingSessionIds = {};
  final Set<int> _pendingLastDispatchRefresh = {};
  bool _isDisposed = false;
  bool selectedRuntimeGarzaWasReleased = false;
  bool _isCreatingDispatchSession = false;
  bool _isRunningSessionAction = false;
  final Map<int, Set<String>> _activeAlarmsByGarza = {};
  final Map<int, _DispatchTimerState> _dispatchTimers = {};
  final Map<int, LastDispatchSnapshot> _lastDispatchesByGarza = {};
  final Map<int, GarzaRuntimeEntity> _runtimeDispatchesByGarza = {};

  bool get isCreatingDispatchSession => _isCreatingDispatchSession;
  bool get isRunningSessionAction => _isRunningSessionAction;
  bool get runtimeStreamInterrupted => _runtimeStreamInterrupted;

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

  List<LastDispatchSnapshot> get lastDispatches =>
      _lastDispatchesByGarza.values.toList()..sort(
        (a, b) => a.session.garzaNumber.compareTo(b.session.garzaNumber),
      );

  List<LastDispatchSnapshot> get lastDispatchesForPanel {
    final activeGarzaNumbers = {
      ...busyGarzas.map((garza) => garza.garzaNumber),
      ...alarmGarzas.map((garza) => garza.garzaNumber),
    };

    return lastDispatches
        .where(
          (dispatch) =>
              !activeGarzaNumbers.contains(dispatch.session.garzaNumber),
        )
        .toList();
  }

  int get runtimePanelGarzasCount =>
      busyGarzasCount + alarmGarzas.length + lastDispatchesForPanel.length;

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

  Future<CtrlResponse<List<PendingDispatchEntity>>> listPendingDispatches({
    int page = 1,
  }) async {
    final response = await pendingPaging.load(
      (number) => pendingDispatchesApi.listPage(
        page: number,
        status: 'pending_dispatch',
      ),
      page: page,
    );
    return CtrlResponse(
      success: response.success,
      message: response.message,
      element: pendingPaging.items,
    );
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

  /// Indicates whether the local dispatch timer is allowed to advance.
  ///
  /// The session state is authoritative for actions confirmed by the API,
  /// while runtime contributes the physical busy/alarm conditions.
  bool shouldRunDispatchTimer(
    DispatchSessionEntity session, {
    GarzaRuntimeEntity? runtimeGarza,
    bool? isBusy,
  }) {
    if (_runtimeStreamInterrupted) return false;
    final runtime = runtimeGarza ?? selectedRuntimeGarza;
    final isSameGarza = runtime?.garzaNumber == session.garzaNumber;
    final isCurrentRuntime =
        isSameGarza && !_isRuntimeSnapshotOlderThanSession(runtime!, session);
    if (isCurrentRuntime &&
        runtime.activeSessionId != null &&
        runtime.activeSessionId != session.id) {
      return false;
    }
    final hasActiveAlarms = isSameGarza && (runtime?.hasActiveAlarms ?? false);
    final runtimeIsBusy = isBusy ?? (isCurrentRuntime ? runtime.isBusy : null);
    final isFinished = _isFinishedSession(session);

    return !isFinished &&
        !hasActiveAlarms &&
        runtimeIsBusy != false &&
        (session.state == DispatchState.dispensing ||
            (session.mode == DispatchMode.manual &&
                session.state != DispatchState.paused));
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
    _selectionRevision++;
    final latest = getRuntimeGarza(garza.garzaNumber);
    final selected =
        latest != null && latest.activeSessionId == garza.activeSessionId
        ? latest
        : garza;
    selectedRuntimeGarza = selected;
    activeSession = _isRuntimeGarzaOccupied(selected)
        ? _sessionFromRuntime(selected)
        : null;
    if (activeSession != null) {
      _runtimeDispatchesByGarza[selected.garzaNumber] = selected;
      _syncDispatchTimer(activeSession!, runtimeGarza: selected);
    }
    selectedRuntimeGarzaWasReleased = false;
    notifyListeners();
  }

  void selectLastDispatch(LastDispatchSnapshot lastDispatch) {
    _selectionRevision++;
    activeSession = lastDispatch.session;
    selectedRuntimeGarza = lastDispatch.runtimeGarza;
    selectedRuntimeGarzaWasReleased = false;
    _syncDispatchTimer(
      lastDispatch.session,
      backendElapsedMs: lastDispatch.dispatchElapsedMs,
      isBusy: false,
    );
    notifyListeners();
  }

  Future<CtrlResponse<DispatchSessionEntity>> createDispatchSession() async {
    if (_isCreatingDispatchSession) {
      return CtrlResponse(
        success: false,
        message: 'El despacho ya se esta procesando',
      );
    }

    _isCreatingDispatchSession = true;
    _selectionRevision++;
    notifyListeners();
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
      selectedRuntimeGarzaWasReleased = false;
      activeSession = await dispatchSessionsApi.getSession(session.id);
      _lastDispatchesByGarza.remove(activeSession!.garzaNumber);
      _syncDispatchTimer(activeSession!);
      notifyListeners();
      return CtrlResponse(success: true, element: activeSession);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    } finally {
      _isCreatingDispatchSession = false;
      notifyListeners();
    }
  }

  Future<CtrlResponse<DispatchSessionEntity>> loadRuntimeSession(
    int sessionId,
  ) async {
    final selectionRevision = _selectionRevision;
    final requestRevision = ++_sessionLoadRevision;
    try {
      final fetched = await dispatchSessionsApi.getSession(sessionId);
      if (_isDisposed ||
          selectionRevision != _selectionRevision ||
          requestRevision != _sessionLoadRevision) {
        return CtrlResponse(
          success: false,
          message: 'La selección de despacho cambió',
        );
      }
      final last = _lastDispatchesByGarza[fetched.garzaNumber];
      var session =
          last?.session.id == sessionId && !_isFinishedSession(fetched)
          ? last!.session
          : fetched;
      final current = activeSession;
      if (current?.id == sessionId &&
          !_isFinishedSession(fetched) &&
          (_isFinishedSession(current!) ||
              _isSessionOlderThan(fetched, current))) {
        session = fetched.copyWith(
          state: current.state,
          authorizedVolume: current.authorizedVolume,
          dispensedVolume: current.dispensedVolume,
          dispatchElapsedMs: current.dispatchElapsedMs,
          updatedAt: current.updatedAt,
        );
      }
      final runtime =
          getRuntimeGarza(session.garzaNumber) ?? selectedRuntimeGarza;
      if (!_isFinishedSession(session) &&
          runtime?.activeSessionId == sessionId &&
          !_isRuntimeSnapshotOlderThanSession(runtime!, session)) {
        session = _sessionFromRuntime(runtime, base: session);
      }
      activeSession = session;
      if (runtime?.garzaNumber == session.garzaNumber) {
        selectedRuntimeGarza = runtime;
      }
      _syncDispatchTimer(session, runtimeGarza: runtime);
      if (_isFinishedSession(fetched) && last?.session.id == sessionId) {
        _rememberLastDispatch(fetched, runtimeGarza: last!.runtimeGarza);
        _pendingLastDispatchRefresh.remove(sessionId);
      }
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
    if (_isRunningSessionAction) {
      return CtrlResponse(
        success: false,
        message: 'La accion del despacho ya se esta procesando',
      );
    }

    final sessionId =
        activeSession?.id ?? selectedRuntimeGarza?.activeSessionId;
    if (sessionId == null) {
      return CtrlResponse(success: false, message: missingMessage);
    }

    _isRunningSessionAction = true;
    final selectionRevision = _selectionRevision;
    final selectedRuntime = selectedRuntimeGarza;
    notifyListeners();
    try {
      final session = await action(sessionId);
      if (_isDisposed) return CtrlResponse(success: true, element: session);
      final runtimeGarza =
          getRuntimeGarza(session.garzaNumber) ?? selectedRuntime;
      if (selectionRevision == _selectionRevision) {
        activeSession = session;
      }
      _syncDispatchTimer(session, runtimeGarza: runtimeGarza);
      if (_isFinishedSession(session)) {
        _rememberLastDispatch(session, runtimeGarza: runtimeGarza);
      }
      notifyListeners();
      return CtrlResponse(success: true, element: session);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    } finally {
      _isRunningSessionAction = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void _startRuntimeStream() {
    if (_isDisposed || _runtimeSubscription != null || !_runtimeStreamEnabled) {
      return;
    }

    final generation = ++_runtimeGeneration;
    _runtimeSubscription = dispatchSessionsApi.streamGarzaRuntime().listen(
      (snapshot) {
        if (_isDisposed || generation != _runtimeGeneration) return;
        _handleRuntimeSnapshot(snapshot);
      },
      onError: (_) {
        if (_isDisposed || generation != _runtimeGeneration) return;
        _runtimeSubscription = null;
        _markRuntimeInterrupted();
        _scheduleRuntimeReconnect();
      },
      onDone: () {
        if (_isDisposed || generation != _runtimeGeneration) return;
        _runtimeSubscription = null;
        _markRuntimeInterrupted();
        _scheduleRuntimeReconnect();
      },
      cancelOnError: true,
    );
    _armRuntimeWatchdog();
  }

  void _stopRuntimeStream() {
    _runtimeGeneration++;
    _runtimeReconnectTimer?.cancel();
    _runtimeWatchdog?.cancel();
    _runtimeSubscription?.cancel();
    _runtimeSubscription = null;
    _runtimeReconnectScheduled = false;
    _hasReceivedRuntimeSnapshot = false;
    runtimeGarzas = [];
    _runtimeDispatchesByGarza.clear();
    _runtimeStreamInterrupted = true;
    for (final timer in _dispatchTimers.values) {
      timer.stop();
    }
    runtimeMessage = null;
    _activeAlarmsByGarza.clear();
    selectedRuntimeGarzaWasReleased = false;
    notifyListeners();
  }

  void _scheduleRuntimeReconnect() {
    if (!_runtimeStreamEnabled || _runtimeReconnectScheduled) return;

    _runtimeReconnectScheduled = true;
    _runtimeReconnectTimer = Timer(const Duration(seconds: 5), () {
      _runtimeReconnectScheduled = false;
      _startRuntimeStream();
    });
  }

  void _markRuntimeInterrupted() {
    _runtimeWatchdog?.cancel();
    _runtimeStreamInterrupted = true;
    runtimeMessage = 'Sin actualizaciones del despacho. Esperando reconexión.';
    for (final timer in _dispatchTimers.values) {
      timer.stop();
    }
    notifyListeners();
  }

  void _armRuntimeWatchdog() {
    _runtimeWatchdog?.cancel();
    // The backend sends a heartbeat at least every five seconds.
    _runtimeWatchdog = Timer(const Duration(seconds: 15), () {
      if (_isDisposed || !_runtimeStreamEnabled) return;
      _runtimeGeneration++;
      final subscription = _runtimeSubscription;
      _runtimeSubscription = null;
      unawaited(subscription?.cancel());
      _markRuntimeInterrupted();
      _scheduleRuntimeReconnect();
    });
  }

  void _handleRuntimeSnapshot(GarzaRuntimeResponseEntity snapshot) {
    _runtimeStreamInterrupted = false;
    _armRuntimeWatchdog();
    runtimeGarzas = snapshot.garzas;
    runtimeMessage = snapshot.message;
    _syncLastDispatchesFromRuntime(snapshot.garzas);
    for (final garza in snapshot.garzas) {
      final sessionId = garza.activeSessionId;
      if (sessionId != null &&
          sessionId != activeSession?.id &&
          _dispatchTimers.containsKey(sessionId)) {
        _syncDispatchTimer(_sessionFromRuntime(garza), runtimeGarza: garza);
      }
    }
    _syncActiveSessionFromRuntime(snapshot.garzas);
    _notifyNewAlarms(snapshot.garzas);
    _hasReceivedRuntimeSnapshot = true;
    notifyListeners();
  }

  void _syncLastDispatchesFromRuntime(List<GarzaRuntimeEntity> garzas) {
    for (final garza in garzas) {
      final previous = _runtimeDispatchesByGarza[garza.garzaNumber];
      final previousUpdatedAt = DateTime.tryParse(previous?.updatedAt ?? '');
      final updatedAt = DateTime.tryParse(garza.updatedAt);
      if (previousUpdatedAt != null &&
          updatedAt != null &&
          updatedAt.isBefore(previousUpdatedAt)) {
        continue;
      }
      final selected = activeSession;
      if (previous != null &&
          selected?.id == previous.activeSessionId &&
          _isRuntimeSnapshotOlderThanSession(garza, selected!)) {
        continue;
      }

      final isOccupied = _isRuntimeGarzaOccupied(garza);
      if (previous != null &&
          (!isOccupied || previous.activeSessionId != garza.activeSessionId)) {
        _runtimeDispatchesByGarza.remove(garza.garzaNumber);
        _rememberReleasedRuntime(previous, garza);
      }

      if (isOccupied) {
        _runtimeDispatchesByGarza[garza.garzaNumber] = garza;
        final last = _lastDispatchesByGarza[garza.garzaNumber];
        if (last != null && last.session.id != garza.activeSessionId) {
          _lastDispatchesByGarza.remove(garza.garzaNumber);
          _pendingLastDispatchRefresh.remove(last.session.id);
        }
      }
    }

    // Track every garza, including sessions that were never opened on screen.
    // Retry provisional records after a failed query or a backend still closing.
    for (final last in _lastDispatchesByGarza.values) {
      if (_pendingLastDispatchRefresh.contains(last.session.id)) {
        unawaited(_refreshSessionFromServer(last.session.id));
      }
    }
  }

  void _rememberReleasedRuntime(
    GarzaRuntimeEntity previous,
    GarzaRuntimeEntity current,
  ) {
    final sessionId = previous.activeSessionId!;
    final hasFinalReading =
        current.activeSessionId == sessionId ||
        ((current.currentState == DispatchState.completed ||
                current.currentState == DispatchState.interrupted) &&
            (current.authorizedVolume > 0 ||
                current.dispensedVolume > 0 ||
                (current.dispatchElapsedMs ?? 0) > 0));
    // A released runtime can reset all counters. Keep the last actual reading
    // until the session endpoint returns the authoritative final values.
    final reading = hasFinalReading ? current : previous;
    final remembered = _lastDispatchesByGarza[previous.garzaNumber]?.session;
    final knownSession = activeSession?.id == sessionId
        ? activeSession
        : remembered?.id == sessionId
        ? remembered
        : null;
    final session = knownSession != null && _isFinishedSession(knownSession)
        ? knownSession
        : (knownSession ?? _sessionFromRuntime(previous)).copyWith(
            state:
                current.currentState == DispatchState.interrupted ||
                    previous.currentState == DispatchState.interrupted
                ? DispatchState.interrupted
                : DispatchState.completed,
            unitOfMeasurement: reading.unitOfMeasurement,
            authorizedVolume: reading.authorizedVolume > 0
                ? reading.authorizedVolume
                : previous.authorizedVolume,
            dispensedVolume: reading.dispensedVolume,
            dispatchElapsedMs: reading.dispatchElapsedMs,
            updatedAt: reading.updatedAt,
          );
    _rememberLastDispatch(session, runtimeGarza: reading);
    _pendingLastDispatchRefresh.add(sessionId);
  }

  void _syncActiveSessionFromRuntime(List<GarzaRuntimeEntity> garzas) {
    final session = activeSession;
    if (session == null) return;
    if (session.state == DispatchState.completed ||
        session.state == DispatchState.interrupted) {
      return;
    }

    final last = _lastDispatchesByGarza[session.garzaNumber];
    if (last?.session.id == session.id) {
      activeSession = last!.session;
      selectedRuntimeGarza = last.runtimeGarza;
      selectedRuntimeGarzaWasReleased = true;
      _syncDispatchTimer(
        activeSession!,
        backendElapsedMs: last.dispatchElapsedMs,
        isBusy: false,
      );
      return;
    }

    final currentGarza = _findRuntimeGarzaByNumber(garzas, session.garzaNumber);
    if (currentGarza != null &&
        _isRuntimeSnapshotOlderThanSession(currentGarza, session)) {
      // The action response (pause/complete/etc.) is newer than this stream
      // event. Keep the confirmed session state so the old snapshot cannot
      // restart the timer or make the UI look active again.
      // Keep the runtime reference updated so a newly reported alarm still
      // stops the timer even when the rest of the snapshot is stale.
      selectedRuntimeGarza = currentGarza;
      selectedRuntimeGarzaWasReleased = false;
      _syncDispatchTimer(session, runtimeGarza: currentGarza);
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
      _refreshSessionFromServer(session.id);
      return;
    }

    selectedRuntimeGarza = runtimeGarza;
    selectedRuntimeGarzaWasReleased = false;
    activeSession = session.copyWith(
      state: runtimeGarza.currentState,
      unitOfMeasurement: runtimeGarza.unitOfMeasurement,
      authorizedVolume: runtimeGarza.authorizedVolume,
      dispensedVolume: runtimeGarza.dispensedVolume,
      dispatchElapsedMs: runtimeGarza.dispatchElapsedMs,
      updatedAt: runtimeGarza.updatedAt,
    );
    _syncDispatchTimer(
      activeSession!,
      backendElapsedMs: runtimeGarza.dispatchElapsedMs,
      isBusy: runtimeGarza.isBusy,
    );
    if (_isFinishedSession(activeSession!)) {
      _rememberLastDispatch(activeSession!, runtimeGarza: runtimeGarza);
    }
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

  DispatchSessionEntity _sessionFromRuntime(
    GarzaRuntimeEntity runtime, {
    DispatchSessionEntity? base,
  }) {
    if (base != null) {
      return base.copyWith(
        state: runtime.currentState,
        mode: runtime.mode,
        unitOfMeasurement: runtime.unitOfMeasurement,
        authorizedVolume: runtime.authorizedVolume,
        dispensedVolume: runtime.dispensedVolume,
        dispatchElapsedMs: runtime.dispatchElapsedMs,
        updatedAt: runtime.updatedAt,
      );
    }
    return DispatchSessionEntity(
      id: runtime.activeSessionId!,
      garzaNumber: runtime.garzaNumber,
      saleFolio: runtime.saleFolio,
      dispatchCode: runtime.dispatchCode,
      operatorUid: null,
      operatorUsername: null,
      mode: runtime.mode,
      unitOfMeasurement: runtime.unitOfMeasurement,
      authorizedVolume: runtime.authorizedVolume,
      dispensedVolume: runtime.dispensedVolume,
      dispatchElapsedMs: runtime.dispatchElapsedMs,
      state: runtime.currentState ?? DispatchState.authorized,
      closeReason: null,
      lastPlcSnapshotJson: null,
      startedAt: null,
      pausedAt: null,
      completedAt: null,
      interruptedAt: null,
      createdAt: runtime.updatedAt,
      updatedAt: runtime.updatedAt,
    );
  }

  bool _runtimeGarzaMatchesSession(
    GarzaRuntimeEntity garza,
    DispatchSessionEntity session,
  ) {
    if (garza.activeSessionId != null) {
      return garza.activeSessionId == session.id;
    }
    if (garza.garzaNumber != session.garzaNumber) return false;

    final sameDispatchCode =
        session.dispatchCode != null &&
        garza.dispatchCode == session.dispatchCode;
    final sameSaleFolio =
        session.saleFolio != null && garza.saleFolio == session.saleFolio;
    final closedByPlc =
        garza.currentState == DispatchState.completed ||
        garza.currentState == DispatchState.interrupted;

    return sameDispatchCode || sameSaleFolio || closedByPlc;
  }

  Future<void> _refreshSessionFromServer(int sessionId) async {
    if (!_refreshingSessionIds.add(sessionId)) return;

    try {
      final refreshedSession = await dispatchSessionsApi.getSession(sessionId);
      if (_isDisposed) return;
      final current = activeSession?.id == sessionId ? activeSession : null;
      final isFinished = _isFinishedSession(refreshedSession);
      if (current != null) {
        if (selectedRuntimeGarzaWasReleased) {
          if (!isFinished) return;
        } else if (_isSessionOlderThan(refreshedSession, current)) {
          return;
        }
      }

      var changed = false;
      final last = _lastDispatchesByGarza[refreshedSession.garzaNumber];
      if (isFinished && last?.session.id == sessionId) {
        _rememberLastDispatch(
          refreshedSession,
          runtimeGarza: last!.runtimeGarza,
        );
        _pendingLastDispatchRefresh.remove(sessionId);
        changed = true;
      }

      if (current != null) {
        activeSession = refreshedSession;
        _syncDispatchTimer(refreshedSession);
        final observed =
            _runtimeDispatchesByGarza[refreshedSession.garzaNumber];
        if (isFinished &&
            (last == null || last.session.id == sessionId) &&
            (observed == null || observed.activeSessionId == sessionId)) {
          _rememberLastDispatch(
            refreshedSession,
            runtimeGarza: selectedRuntimeGarza,
          );
          _pendingLastDispatchRefresh.remove(sessionId);
        }
        changed = true;
      }
      if (changed) notifyListeners();
    } on AppException {
      // The runtime stream will keep trying on the next snapshot.
    } finally {
      _refreshingSessionIds.remove(sessionId);
    }
  }

  void _notifyNewAlarms(List<GarzaRuntimeEntity> garzas) {
    ToastService? toastService;

    for (final garza in garzas) {
      final previousAlarms = _activeAlarmsByGarza[garza.garzaNumber] ?? {};
      final currentAlarms = garza.activeAlarmNames.toSet();

      if (_hasReceivedRuntimeSnapshot) {
        final newAlarms = currentAlarms.difference(previousAlarms);
        for (final alarm in newAlarms) {
          (toastService ??= locator<ToastService>()).error(
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

  bool _isFinishedSession(DispatchSessionEntity session) {
    return session.state == DispatchState.completed ||
        session.state == DispatchState.interrupted;
  }

  bool _isRuntimeSnapshotOlderThanSession(
    GarzaRuntimeEntity runtimeGarza,
    DispatchSessionEntity session,
  ) {
    final runtimeUpdatedAt = DateTime.tryParse(runtimeGarza.updatedAt);
    final sessionUpdatedAt = DateTime.tryParse(session.updatedAt);
    if (runtimeUpdatedAt == null || sessionUpdatedAt == null) return false;
    return runtimeUpdatedAt.isBefore(sessionUpdatedAt);
  }

  bool _isSessionOlderThan(
    DispatchSessionEntity candidate,
    DispatchSessionEntity current,
  ) {
    final candidateUpdatedAt = DateTime.tryParse(candidate.updatedAt);
    final currentUpdatedAt = DateTime.tryParse(current.updatedAt);
    if (candidateUpdatedAt == null || currentUpdatedAt == null) return false;
    return candidateUpdatedAt.isBefore(currentUpdatedAt);
  }

  void _rememberLastDispatch(
    DispatchSessionEntity session, {
    required GarzaRuntimeEntity? runtimeGarza,
  }) {
    final elapsedMs =
        session.dispatchElapsedMs ?? runtimeGarza?.dispatchElapsedMs;
    final normalizedSession =
        elapsedMs == null || session.dispatchElapsedMs != null
        ? session
        : session.copyWith(dispatchElapsedMs: elapsedMs);

    _lastDispatchesByGarza[session.garzaNumber] = LastDispatchSnapshot(
      session: normalizedSession,
      runtimeGarza: runtimeGarza,
    );
    _syncDispatchTimer(
      normalizedSession,
      runtimeGarza: runtimeGarza,
      isBusy: false,
    );
  }

  void _syncDispatchTimer(
    DispatchSessionEntity session, {
    int? backendElapsedMs,
    bool? isBusy,
    GarzaRuntimeEntity? runtimeGarza,
  }) {
    final timer = _dispatchTimers.putIfAbsent(
      session.id,
      _DispatchTimerState.new,
    );

    final shouldRun = shouldRunDispatchTimer(
      session,
      isBusy: isBusy,
      runtimeGarza:
          runtimeGarza ??
          getRuntimeGarza(session.garzaNumber) ??
          selectedRuntimeGarza,
    );
    final synchronizedElapsedMs = backendElapsedMs ?? session.dispatchElapsedMs;
    if (synchronizedElapsedMs != null) {
      timer.synchronize(
        Duration(milliseconds: synchronizedElapsedMs),
        preserveProgress: shouldRun && timer.isRunning,
      );
    }

    if (shouldRun) {
      timer.start();
    } else {
      timer.stop();
    }
  }

  @override
  void dispose() {
    pendingPaging.dispose();
    _isDisposed = true;
    _runtimeGeneration++;
    _runtimeWatchdog?.cancel();
    _runtimeReconnectTimer?.cancel();
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
  bool get isRunning => _sinceSynchronization.isRunning;

  void synchronize(Duration elapsed, {bool preserveProgress = false}) {
    if (preserveProgress && elapsed <= _synchronizedElapsed) return;
    final current = this.elapsed;
    if (preserveProgress && elapsed < current) elapsed = current;
    _synchronizedElapsed = elapsed.isNegative ? Duration.zero : elapsed;
    _sinceSynchronization
      ..stop()
      ..reset();
  }

  void start() => _sinceSynchronization.start();

  void stop() => _sinceSynchronization.stop();
}
