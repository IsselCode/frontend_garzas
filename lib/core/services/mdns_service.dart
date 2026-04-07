import 'dart:convert';
import 'dart:io';
import 'package:nsd/nsd.dart';

import '../../commons/entities/device_entity.dart';

class MdnsService {
  Future<DeviceEntity?> discoverWithNsd() async {
    try {
      final discovery = await startDiscovery(
        '_http._tcp',
        ipLookupType: IpLookupType.v4,
      );
      final out = <DeviceEntity>[];

      discovery.addServiceListener((service, status) async {
        final resolved = await resolve(service);
        final ipv4 = resolved.addresses?.cast<InternetAddress?>().firstWhere(
          (address) => address?.type == InternetAddressType.IPv4,
          orElse: () => null,
        );
        final host = ipv4?.address ?? resolved.host ?? '';
        final port = resolved.port ?? 80;
        final Map<String, dynamic> txt = {
          for (final entry in (resolved.txt ?? {}).entries)
            entry.key: (entry.value is List<int>)
                ? utf8.decode(entry.value as List<int>)
                : entry.value.toString(),
        };

        out.add(
          DeviceEntity(
            name: resolved.name ?? '',
            host: host,
            port: port,
            txt: txt,
          ),
        );
      });

      // Espera ~3–5 s a que aparezcan
      await Future.delayed(const Duration(seconds: 5));
      await stopDiscovery(discovery);
      return out.isNotEmpty ? out.first : null;
    } catch (e) {
      print(e);
      throw UnimplementedError();
    }
  }
}
