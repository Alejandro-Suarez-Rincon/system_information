class DeviceStats {
  final String deviceName;
  final String osVersion;
  final int batteryPercentage;
  final int cpuUsage;
  final int ramUsage;
  final int ramTotal;
  final int storageUsed;
  final int storageTotal;

  DeviceStats({
    required this.deviceName,
    required this.osVersion,
    required this.batteryPercentage,
    required this.cpuUsage,
    required this.ramUsage,
    required this.ramTotal,
    required this.storageUsed,
    required this.storageTotal,
  });
}