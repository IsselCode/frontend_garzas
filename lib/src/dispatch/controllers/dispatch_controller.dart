import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/ctrl_response.dart';
import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/src/admin/clean/entities/config_garza_entity.dart';
import 'package:frontend_garzas/src/admin/clean/entities/sale_entity.dart';
import 'package:frontend_garzas/src/admin/data/garzas_api.dart';
import 'package:frontend_garzas/src/admin/data/sales_api.dart';
import 'package:frontend_garzas/src/dispatch/data/dispatch_sessions_api.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_validate_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';

import '../../../core/services/toast_service.dart';
import '../../../inject_container.dart';

class DispatchController extends ChangeNotifier {
  SalesApi salesApi;
  GarzasApi garzasApi;
  DispatchSessionsApi dispatchSessionsApi;

  DispatchController({
    required this.salesApi,
    required this.garzasApi,
    required this.dispatchSessionsApi,
  });

  DispatchValidateEntity? dispatchValidate;
  List<ConfigGarzaEntity> availableGarzas = [];
  ConfigGarzaEntity? selectedGarza;

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
      final session = await dispatchSessionsApi.createSession(
        dispatchCode: dispatchValidate!.dispatchCode,
        garzaNumber: selectedGarza!.number,
      );

      selectedRuntimeGarza = null;
      _selectedRuntimeGarzaStartedOccupied = false;
      selectedRuntimeGarzaWasReleased = false;
      activeSession = await dispatchSessionsApi.getSession(session.id);
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
      authorizedVolumeLiters: runtimeGarza.authorizedVolumeLiters,
      dispensedVolumeFinalLiters: runtimeGarza.dispensedVolumeLiters,
      updatedAt: runtimeGarza.updatedAt,
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
      dispatchValidate = validate;
      return CtrlResponse(success: true);
    } on AppException catch (e) {
      return CtrlResponse(success: false, message: e.message);
    }
  }

  Future<CtrlResponse> getAvailableGarzas() async {
    try {
      List<ConfigGarzaEntity> tempGarzas = await garzasApi.listGarzas(
        waterType: dispatchValidate!.waterType,
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

  @override
  void dispose() {
    _runtimeSubscription?.cancel();
    super.dispose();
  }
}
