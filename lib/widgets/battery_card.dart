import 'package:flutter/material.dart';
import 'package:system_information/theme/app_theme.dart';
import 'package:system_information/widgets/stat_card.dart';

/// Tarjeta de batería (estilo oscuro) con color e icono según nivel y carga.
class BatteryCard extends StatelessWidget {
  final int percentage;
  final bool isCharging;

  const BatteryCard({
    super.key,
    required this.percentage,
    this.isCharging = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = percentage > 50
        ? AppColors.ok
        : percentage > 20
            ? AppColors.warning
            : AppColors.danger;

    IconData icon;
    if (isCharging) {
      icon = Icons.battery_charging_full;
    } else if (percentage > 80) {
      icon = Icons.battery_full;
    } else if (percentage > 30) {
      icon = Icons.battery_5_bar;
    } else {
      icon = Icons.battery_2_bar;
    }

    return StatCard(
      title: 'Batería',
      value: '$percentage',
      unit: '%',
      icon: icon,
      color: color,
      percentage: percentage.toDouble(),
      trailing: isCharging
          ? Row(
              children: [
                Icon(Icons.bolt, color: color, size: 16),
                const SizedBox(width: 2),
                Text(
                  'Cargando',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            )
          : null,
    );
  }
}
