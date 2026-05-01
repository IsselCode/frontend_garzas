import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart';

import '../../commons/entities/device_entity.dart';

class MdnsService {
  static const String _serviceType = '_http._tcp';
  static const Duration _discoveryTimeout = Duration(seconds: 8);

  Future<DeviceEntity?> discoverWithNsd() async {
    Discovery? discovery;

    try {
      if (kDebugMode) {
        enableLogging(LogTopic.errors);
      }

      discovery = await startDiscovery(
        _serviceType,
        ipLookupType: IpLookupType.v4,
      );
      final completer = Completer<DeviceEntity?>();

      discovery.addServiceListener((service, status) {
        if (status != ServiceStatus.found) return;
        final device = _toDevice(service);
        if (device == null || completer.isCompleted) return;
        completer.complete(device);
      });

      for (final service in discovery.services) {
        final device = _toDevice(service);
        if (device != null) return device;
      }

      return completer.future.timeout(_discoveryTimeout, onTimeout: () => null);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error descubriendo servicio mDNS: $error');
        debugPrint('$stackTrace');
      }
      return null;
    } finally {
      if (discovery != null) {
        await stopDiscovery(discovery);
      }
    }
  }

  DeviceEntity? _toDevice(Service service) {
    final host = _resolveHost(service);
    if (host.isEmpty) return null;

    return DeviceEntity(
      name: service.name ?? '',
      host: host,
      port: service.port ?? 80,
      txt: _decodeTxt(service.txt),
    );
  }

  String _resolveHost(Service service) {
    final ipv4 = service.addresses
        ?.where((address) => address.type == InternetAddressType.IPv4)
        .firstOrNull;

    final host = ipv4?.address ?? service.host ?? '';
    return host.endsWith('.') ? host.substring(0, host.length - 1) : host;
  }

  Map<String, dynamic> _decodeTxt(Map<String, List<int>?>? txt) {
    return {
      for (final entry in (txt ?? {}).entries)
        entry.key: entry.value == null ? null : utf8.decode(entry.value!),
    };
  }
}
