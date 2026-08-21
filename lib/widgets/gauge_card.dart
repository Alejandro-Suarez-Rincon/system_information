import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:system_information/theme/app_theme.dart';

/// Tarjeta con un gauge circular (anillo de progreso) para una métrica.
class GaugeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  /// Porcentaje 0-100. Si es negativo se muestra "n/d".
  final double percent;

  /// Texto central grande (p. ej. "42%").
  final String centerText;

  /// Texto secundario bajo el valor (p. ej. "6.1 / 8 GB").
  final String? subtitle;

  const GaugeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.percent,
    required this.centerText,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final available = percent >= 0;
    final ringColor = available ? color : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ringColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _GaugePainter(
                  percent: available ? percent.clamp(0, 100) : 0,
                  color: ringColor,
                  trackColor: AppColors.surfaceHigh,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        centerText,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trackColor;

  _GaugePainter({
    required this.percent,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 11.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    // Arco de 270° empezando abajo-izquierda.
    const startAngle = math.pi * 0.75;
    const sweepMax = math.pi * 1.5;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepMax,
        colors: [color.withValues(alpha: 0.55), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepMax, false, track);
    canvas.drawArc(rect, startAngle, sweepMax * (percent / 100), false, progress);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.percent != percent || old.color != color;
}
