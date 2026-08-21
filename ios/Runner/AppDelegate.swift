import Flutter
import UIKit
import Darwin

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let metrics = SystemMetrics()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SystemMetrics") {
      let channel = FlutterMethodChannel(
        name: "system_information/metrics",
        binaryMessenger: registrar.messenger()
      )
      let metrics = self.metrics
      channel.setMethodCallHandler { call, result in
        if call.method == "getMetrics" {
          result(metrics.snapshot())
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}

/// Lee CPU y RAM del sistema usando las APIs mach de Darwin.
/// Funciona igual en iOS y macOS.
final class SystemMetrics {
  // Muestra anterior para el delta de CPU.
  private var prevTotal: Double = 0
  private var prevIdle: Double = 0

  func snapshot() -> [String: Any] {
    let storage = storageInfo()
    return [
      "cpuUsage": cpuUsage(),
      "cpuMode": "usage",
      "cpuDetail": "",
      "ramTotal": Int(ramTotal()),
      "ramUsed": Int(ramUsed()),
      "storageTotal": storage.total,
      "storageUsed": storage.used,
    ]
  }

  /// Capacidad total y usada del volumen principal, en bytes.
  private func storageInfo() -> (total: Int, used: Int) {
    let url = URL(fileURLWithPath: NSHomeDirectory())
    do {
      let values = try url.resourceValues(
        forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
      let total = values.volumeTotalCapacity ?? 0
      let free = values.volumeAvailableCapacity ?? 0
      return (total, max(0, total - free))
    } catch {
      return (0, 0)
    }
  }

  /// Uso de CPU 0-100. Devuelve -1 en la primera llamada (sin línea base) o si falla.
  private func cpuUsage() -> Double {
    var cpuLoad = host_cpu_load_info()
    var count = mach_msg_type_number_t(
      MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
    let kr = withUnsafeMutablePointer(to: &cpuLoad) { ptr -> kern_return_t in
      ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
        host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, intPtr, &count)
      }
    }
    guard kr == KERN_SUCCESS else { return -1 }

    let user = Double(cpuLoad.cpu_ticks.0)
    let system = Double(cpuLoad.cpu_ticks.1)
    let idle = Double(cpuLoad.cpu_ticks.2)
    let nice = Double(cpuLoad.cpu_ticks.3)
    let total = user + system + idle + nice

    let totalDelta = total - prevTotal
    let idleDelta = idle - prevIdle
    prevTotal = total
    prevIdle = idle

    guard totalDelta > 0 else { return -1 }
    let usage = (1.0 - idleDelta / totalDelta) * 100.0
    return min(100, max(0, usage))
  }

  private func ramTotal() -> UInt64 {
    return ProcessInfo.processInfo.physicalMemory
  }

  /// RAM en uso (active + wired + comprimida) en bytes.
  private func ramUsed() -> UInt64 {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(
      MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
    let kr = withUnsafeMutablePointer(to: &stats) { ptr -> kern_return_t in
      ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
        host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
      }
    }
    guard kr == KERN_SUCCESS else { return 0 }

    let pageSize = UInt64(vm_page_size)
    let active = UInt64(stats.active_count)
    let wired = UInt64(stats.wire_count)
    let compressed = UInt64(stats.compressor_page_count)
    return (active + wired + compressed) * pageSize
  }
}
