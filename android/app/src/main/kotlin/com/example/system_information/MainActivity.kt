package com.example.system_information

import android.app.ActivityManager
import android.content.Context
import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.RandomAccessFile

class MainActivity : FlutterActivity() {
    private val channelName = "system_information/metrics"

    // Muestra anterior de /proc/stat para calcular el delta de uso de CPU.
    private var prevTotal = 0L
    private var prevIdle = 0L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getMetrics" -> result.success(getMetrics())
                    else -> result.notImplemented()
                }
            }
    }

    private fun getMetrics(): Map<String, Any> {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mem = ActivityManager.MemoryInfo()
        am.getMemoryInfo(mem)

        val stat = StatFs(Environment.getDataDirectory().path)
        val storageTotal = stat.blockSizeLong * stat.blockCountLong
        val storageFree = stat.blockSizeLong * stat.availableBlocksLong

        val cpu = readCpu()

        return mapOf(
            "cpuUsage" to cpu.percent,
            "cpuMode" to cpu.mode,
            "cpuDetail" to cpu.detail,
            "ramTotal" to mem.totalMem,
            "ramUsed" to (mem.totalMem - mem.availMem),
            "storageTotal" to storageTotal,
            "storageUsed" to (storageTotal - storageFree)
        )
    }

    private data class CpuReading(val percent: Double, val mode: String, val detail: String)

    /// Estrategia de CPU en Android:
    /// 1) intenta /proc/stat (uso real del sistema) — bloqueado por SELinux en Android 8+.
    /// 2) si falla, usa la frecuencia de los núcleos (cur/max) como indicador en vivo.
    private fun readCpu(): CpuReading {
        val usage = readCpuUsageProc()
        if (usage >= 0) return CpuReading(usage, "usage", "")
        return readCpuFrequency()
    }

    /// Uso de CPU (0-100) leyendo /proc/stat. Devuelve -1 si el sistema lo
    /// restringe (SELinux en Android 8+) o si aún no hay muestra previa.
    private fun readCpuUsageProc(): Double {
        return try {
            val load = RandomAccessFile("/proc/stat", "r").use { it.readLine() }
            val toks = load.split(" ").filter { it.isNotEmpty() }
            // toks[0] == "cpu"; user nice system idle iowait irq softirq
            val user = toks[1].toLong()
            val nice = toks[2].toLong()
            val system = toks[3].toLong()
            val idle = toks[4].toLong()
            val iowait = toks[5].toLong()
            val irq = toks[6].toLong()
            val softirq = toks[7].toLong()

            val idleAll = idle + iowait
            val total = user + nice + system + idleAll + irq + softirq
            val totalDelta = total - prevTotal
            val idleDelta = idleAll - prevIdle
            prevTotal = total
            prevIdle = idleAll

            if (totalDelta <= 0L) return -1.0
            val usage = (1.0 - idleDelta.toDouble() / totalDelta.toDouble()) * 100.0
            usage.coerceIn(0.0, 100.0)
        } catch (e: Exception) {
            -1.0
        }
    }

    /// Carga por frecuencia: promedio de scaling_cur_freq / cpuinfo_max_freq
    /// en todos los núcleos legibles. Devuelve el % y la frecuencia media en GHz.
    private fun readCpuFrequency(): CpuReading {
        var sumCur = 0L
        var sumMax = 0L
        var count = 0
        val cores = Runtime.getRuntime().availableProcessors()

        for (i in 0 until cores) {
            try {
                val base = "/sys/devices/system/cpu/cpu$i/cpufreq"
                val cur = File("$base/scaling_cur_freq").readText().trim().toLongOrNull() ?: continue
                val max = File("$base/cpuinfo_max_freq").readText().trim().toLongOrNull()
                    ?: File("$base/scaling_max_freq").readText().trim().toLongOrNull()
                    ?: continue
                if (max <= 0L) continue
                sumCur += cur
                sumMax += max
                count++
            } catch (e: Exception) {
                // Núcleo apagado o restringido: se omite.
            }
        }

        if (count == 0 || sumMax <= 0L) return CpuReading(-1.0, "frequency", "")

        val percent = (sumCur.toDouble() / sumMax.toDouble() * 100.0).coerceIn(0.0, 100.0)
        val avgGhz = (sumCur.toDouble() / count) / 1_000_000.0
        return CpuReading(percent, "frequency", String.format("%.1f GHz", avgGhz))
    }
}
