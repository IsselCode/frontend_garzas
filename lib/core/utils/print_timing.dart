import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class PrintTiming {
  PrintTiming(this.operation)
    : _id = DateTime.now().microsecondsSinceEpoch,
      _startedAt = DateTime.now(),
      _total = Stopwatch()..start();

  static const Duration _slowThreshold = Duration(milliseconds: 2000);
  static const String _logFilePath =
      r'C:\ProgramData\BackendGarzas\logs\impresoras.txt';
  static Future<void> _writeQueue = Future<void>.value();

  final String operation;
  final int _id;
  final DateTime _startedAt;
  final Stopwatch _total;
  final List<String> _events = [];

  bool _finished = false;

  void event(String message) {
    final logLine = '[+${_total.elapsedMilliseconds} ms] $message';
    _events.add(logLine);
    debugPrint(
      '[PRINT_TIMING][$_id][$operation]'
      '$logLine',
    );
  }

  Future<T> measure<T>(String phase, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      event('$phase: ${stopwatch.elapsedMilliseconds} ms');
    }
  }

  Future<void> finish() async {
    if (_finished) return;
    _finished = true;
    _total.stop();
    final total = _total.elapsed;
    debugPrint(
      '[PRINT_TIMING][$_id][$operation]'
      ' TOTAL desde el clic: ${total.inMilliseconds} ms',
    );

    if (!Platform.isWindows || total <= _slowThreshold) return;
    await _appendToLog(_completedRecord(total));
  }

  String _completedRecord(Duration total) {
    return _formatRecord('OPERACIÓN LENTA COMPLETADA', [
      'Fin: ${DateTime.now().toIso8601String()}',
      'Duración total: ${total.inMilliseconds} ms',
      ..._events,
    ]);
  }

  String _formatRecord(String title, List<String> lines) {
    return [
      '===== $title =====',
      'Inicio: ${_startedAt.toIso8601String()}',
      'Id: $_id',
      'Operación: $operation',
      ...lines,
      '',
    ].join('\r\n');
  }

  static Future<bool> _appendToLog(String record) {
    final completer = Completer<bool>();
    _writeQueue = _writeQueue.then((_) async {
      try {
        final file = File(_logFilePath);
        await file.parent.create(recursive: true);
        await file.writeAsString(
          '$record\r\n',
          mode: FileMode.append,
          flush: true,
        );
        completer.complete(true);
      } catch (error) {
        debugPrint('[PRINT_TIMING] No se pudo escribir $_logFilePath: $error');
        completer.complete(false);
      }
    });
    return completer.future;
  }
}
