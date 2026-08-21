import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../models/device_stats.dart';
import '../widgets/battery_card.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DeviceService _deviceService;
  DeviceStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _deviceService.getDeviceStats();
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('System Information'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.all(10),
                children: [
                  // Información del dispositivo
                  StatCard(
                    title: 'Device',
                    value: _stats?.deviceName ?? 'Unknown',
                    unit: _stats?.osVersion ?? '',
                    icon: Icons.smartphone,
                    color: Colors.blue,
                  ),

                  // Batería
                  BatteryCard(percentage: _stats?.batteryPercentage ?? 0),

                  // RAM
                  StatCard(
                    title: 'RAM',
                    value: '${_stats?.ramUsage}',
                    unit: 'MB / ${_stats?.ramTotal}MB',
                    icon: Icons.memory,
                    color: Colors.purple,
                    percentage: ((_stats?.ramUsage ?? 0) / 
                        (_stats?.ramTotal ?? 1) * 100),
                  ),

                  // Almacenamiento
                  StatCard(
                    title: 'Storage',
                    value: '${_stats?.storageUsed}',
                    unit: 'MB / ${_stats?.storageTotal}MB',
                    icon: Icons.storage,
                    color: Colors.orange,
                    percentage: ((_stats?.storageUsed ?? 0) / 
                        (_stats?.storageTotal ?? 1) * 100),
                  ),

                  // CPU
                  StatCard(
                    title: 'CPU',
                    value: '${_stats?.cpuUsage}',
                    unit: '%',
                    icon: Icons.speed,
                    color: Colors.red,
                    percentage: (_stats?.cpuUsage ?? 0).toDouble(),
                  ),
                ],
              ),
            ),
    );
  }
}