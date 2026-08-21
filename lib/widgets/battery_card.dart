import 'package:flutter/material.dart';
import 'stat_card.dart';

class BatteryCard extends StatelessWidget {
  final int percentage;

  const BatteryCard({required this.percentage});

  @override
  Widget build(BuildContext context) {
    Color color = percentage > 50
        ? Colors.green
        : percentage > 20
            ? Colors.orange
            : Colors.red;

    return StatCard(
      title: 'Batería',
      value: '$percentage',
      unit: '%',
      icon: Icons.battery_full,
      color: color,
      percentage: percentage.toDouble(),
    );
  }
}
