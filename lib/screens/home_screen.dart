import 'dart:async';

import 'package:flutter/material.dart';
import 'package:system_information/models/device_stats.dart';
import 'package:system_information/services/device_service.dart';
import 'package:system_information/theme/app_theme.dart';
import 'package:system_information/utils/formatters.dart';
import 'package:system_information/widgets/battery_card.dart';
import 'package:system_information/widgets/gauge_card.dart';
import 'package:system_information/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _deviceService = DeviceService();
  static const _refreshInterval = Duration(milliseconds: 2500);

  DeviceStats _stats = DeviceStats.empty();
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(_refreshInterval, (_) => _loadData(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    try {
      final stats = await _deviceService.getDeviceStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!silent) _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.cpu,
                backgroundColor: AppColors.surface,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    if (_error != null) _errorBanner(),
                    _gaugeRow(),
                    const SizedBox(height: 14),
                    BatteryCard(
                      percentage: _stats.batteryPercentage,
                      isCharging: _stats.isCharging,
                    ),
                    const SizedBox(height: 14),
                    _storageCard(),
                    const SizedBox(height: 14),
                    _deviceCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.ok,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'System Monitor',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_stats.deviceName} · en vivo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _gaugeRow() {
    final ramPct = percentOf(_stats.ramUsed, _stats.ramTotal);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GaugeCard(
            title: 'CPU',
            icon: Icons.memory,
            color: AppColors.cpu,
            percent: _stats.hasCpuUsage ? _stats.cpuUsage : -1,
            centerText: _stats.hasCpuUsage
                ? '${_stats.cpuUsage.round()}%'
                : 'n/d',
            subtitle: '${_stats.cpuCores} núcleos',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GaugeCard(
            title: 'RAM',
            icon: Icons.developer_board,
            color: AppColors.ram,
            percent: _stats.ramTotal > 0 ? ramPct : -1,
            centerText:
                _stats.ramTotal > 0 ? '${ramPct.round()}%' : 'n/d',
            subtitle: _stats.ramTotal > 0
                ? '${formatBytes(_stats.ramUsed)} / ${formatBytes(_stats.ramTotal)}'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _storageCard() {
    final pct = percentOf(_stats.storageUsed, _stats.storageTotal);
    return StatCard(
      title: 'Almacenamiento',
      icon: Icons.storage,
      color: AppColors.storage,
      value: formatBytes(_stats.storageUsed),
      unit: '/ ${formatBytes(_stats.storageTotal)}',
      percentage: _stats.storageTotal > 0 ? pct : null,
    );
  }

  Widget _deviceCard() {
    return StatCard(
      title: 'Dispositivo',
      icon: Icons.devices,
      color: AppColors.textSecondary,
      value: _stats.deviceName,
      unit: _stats.cpuArch.isNotEmpty ? _stats.cpuArch : null,
      trailing: Text(
        _stats.osVersion,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No se pudieron leer algunos datos: $_error',
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
