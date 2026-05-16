import 'dart:convert';

import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:frontend_garzas/core/services/api_client.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_event_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/dispatch_session_entity.dart';
import 'package:frontend_garzas/src/dispatch/entities/garza_runtime_entity.dart';

class DispatchSessionsApi {
  final ApiClient apiClient;

  DispatchSessionsApi({required this.apiClient});

  final String _sessionsPath = '/dispatch-sessions';
  final String _runtimeStreamPath = '/garzas/runtime/stream';

  Future<DispatchSessionEntity> createSession({
    required String dispatchCode,
    required int garzaNumber,
  }) async {
    try {
      final response = await apiClient.post(
        _sessionsPath,
        authRequired: true,
        body: {'dispatch_code': dispatchCode, 'garza_number': garzaNumber},
      );

      return DispatchSessionEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<DispatchSessionEntity> getSession(int sessionId) async {
    try {
      final response = await apiClient.get(
        '$_sessionsPath/$sessionId',
        authRequired: true,
      );

      return DispatchSessionEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<DispatchEventEntity>> listSessionEvents(int sessionId) async {
    try {
      final List response = await apiClient.get(
        '$_sessionsPath/$sessionId/events',
        authRequired: true,
      );

      return response.map((e) => DispatchEventEntity.fromMap(e)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<DispatchSessionEntity> startSession(int sessionId) {
    return _postSessionAction(sessionId, 'start');
  }

  Future<DispatchSessionEntity> pauseSession(int sessionId) {
    return _postSessionAction(sessionId, 'pause');
  }

  Future<DispatchSessionEntity> resumeSession(int sessionId) {
    return _postSessionAction(sessionId, 'resume');
  }

  Future<DispatchSessionEntity> completeSession(int sessionId) {
    return _postSessionAction(sessionId, 'complete');
  }

  Stream<GarzaRuntimeResponseEntity> streamGarzaRuntime() async* {
    try {
      final stream = await apiClient.getTextStream(
        _runtimeStreamPath,
        authRequired: true,
        headers: {'Accept': 'text/event-stream'},
      );

      var buffer = '';

      await for (final chunk in stream) {
        buffer += chunk.replaceAll('\r\n', '\n');

        while (buffer.contains('\n\n')) {
          final separatorIndex = buffer.indexOf('\n\n');
          final rawEvent = buffer.substring(0, separatorIndex);
          buffer = buffer.substring(separatorIndex + 2);

          final data = _extractSseData(rawEvent);
          if (data == null || data.isEmpty) continue;

          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            yield GarzaRuntimeResponseEntity.fromMap(decoded);
          }
        }
      }
    } on AppException {
      rethrow;
    } catch (e) {
      apiClient.serverStatusController.markUnavailable();
      throw AppException(message: e.toString());
    }
  }

  Future<DispatchSessionEntity> _postSessionAction(
    int sessionId,
    String action,
  ) async {
    try {
      final response = await apiClient.post(
        '$_sessionsPath/$sessionId/$action',
        authRequired: true,
      );

      return DispatchSessionEntity.fromMap(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  String? _extractSseData(String rawEvent) {
    final dataLines = rawEvent
        .split('\n')
        .where((line) => line.startsWith('data:'))
        .map((line) => line.substring(5).trimLeft())
        .toList();

    if (dataLines.isEmpty) return null;
    return dataLines.join('\n');
  }
}
