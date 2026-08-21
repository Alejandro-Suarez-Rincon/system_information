/// Utilidades de formato para valores del sistema.
library;

/// Convierte una cantidad de bytes en una cadena legible (KB, MB, GB, TB).
///
/// Ejemplo: `formatBytes(6442450944)` -> `"6.0 GB"`.
String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var size = bytes.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  return '${size.toStringAsFixed(unit == 0 ? 0 : decimals)} ${units[unit]}';
}

/// Devuelve el porcentaje (0-100) que representa [used] sobre [total].
/// Protegido frente a divisiones por cero.
double percentOf(num used, num total) {
  if (total <= 0) return 0;
  final pct = (used / total) * 100;
  if (pct.isNaN || pct.isInfinite) return 0;
  return pct.clamp(0, 100).toDouble();
}
