import 'package:flutter/services.dart';

/// Resultado del canal nativo de métricas.
class NativeMetrics {
  /// Valor 0-100 para el gauge de CPU, o negativo si no está disponible.
  /// Su significado depende de [cpuMode].
  final double cpuUsage;

  /// "usage" = uso real del sistema (macOS/iOS).
  /// "frequency" = carga por frecuencia de núcleos (Android).
  final String cpuMode;

  /// Detalle textual opcional de CPU (p. ej. "1.5 GHz").
  final String cpuDetail;

  /// RAM total y en uso, en bytes.
  final int ramTotal;
  final int ramUsed;

  /// Almacenamiento total y en uso, en bytes.
  final int storageTotal;
  final int storageUsed;

  const NativeMetrics({
    required this.cpuUsage,
    required this.cpuMode,
    required this.cpuDetail,
    required this.ramTotal,
    required this.ramUsed,
    required this.storageTotal,
    required this.storageUsed,
  });

  static const NativeMetrics unavailable = NativeMetrics(
    cpuUsage: -1,
    cpuMode: 'usage',
    cpuDetail: '',
    ramTotal: 0,
    ramUsed: 0,
    storageTotal: 0,
    storageUsed: 0,
  );
}

/// Puente hacia el código nativo (Kotlin/Swift) que expone CPU% y RAM
/// para Android, iOS y macOS a través de un [MethodChannel].
class MetricsChannel {
  static const _channel = MethodChannel('system_information/metrics');

  Future<NativeMetrics> getMetrics() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getMetrics');
      if (result == null) return NativeMetrics.unavailable;
      return NativeMetrics(
        cpuUsage: (result['cpuUsage'] as num?)?.toDouble() ?? -1,
        cpuMode: (result['cpuMode'] as String?) ?? 'usage',
        cpuDetail: (result['cpuDetail'] as String?) ?? '',
        ramTotal: (result['ramTotal'] as num?)?.toInt() ?? 0,
        ramUsed: (result['ramUsed'] as num?)?.toInt() ?? 0,
        storageTotal: (result['storageTotal'] as num?)?.toInt() ?? 0,
        storageUsed: (result['storageUsed'] as num?)?.toInt() ?? 0,
      );
    } on PlatformException {
      return NativeMetrics.unavailable;
    } on MissingPluginException {
      // La plataforma no implementa el canal (p. ej. web/Windows/Linux).
      return NativeMetrics.unavailable;
    }
  }
}
