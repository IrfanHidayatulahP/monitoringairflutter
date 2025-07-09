import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monitoringair/components/control_panel.dart';
import 'package:monitoringair/components/realtime_chart.dart';
import 'package:monitoringair/components/safe_limit_modal.dart';
import 'package:monitoringair/components/status_card.dart';
import 'package:monitoringair/components/water_tank_visualization.dart';
import 'package:monitoringair/models/chart_data.dart';
import 'package:monitoringair/service/service.dart';
import 'package:monitoringair/utils/constants.dart';
import 'dart:math';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // Sensor and chart data
  double currentWaterLevel = 0.0;
  double distanceCm = 0.0;
  final double maxDistance = 20.0;
  final double minDistance = 5.0;
  double safeLimit = 85.0;
  List<FlSpot> chartData = [];
  Timer? _timer;

  // Animations
  late final AnimationController _waveController;
  late final AnimationController _glowController;
  late SensorService sensorService;

  // Base URL untuk API
  final String _baseUrl = "https://e83eca43a336.ngrok-free.app";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeChart();
    _startPolling();
    sensorService = SensorService(baseUrl: _baseUrl);

  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  void _initializeChart() {
    for (int i = 0; i < 10; i++) {
      chartData.add(FlSpot(i.toDouble(), 0));
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchLatestSensor(),
    );
  }

  // Future<void> _fetchLatestSensor() async {
  //   final url = Uri.parse('$_baseUrl/sensor/get');
  //   try {
  //     final resp = await http.get(url);
  //     if (resp.statusCode == 200) {
  //       final list = jsonDecode(resp.body) as List;
  //       if (list.isNotEmpty) {
  //         final data = list.first as Map<String, dynamic>;
  //         distanceCm = (data['distance'] as num).toDouble();

  //         // Calculate percentage in 5 steps
  //         double raw = ((maxDistance - distanceCm) /
  //                 (maxDistance - minDistance)) *
  //             100;
  //         raw = raw.clamp(0.0, 100.0);
  //         currentWaterLevel = (raw / 25).round() * 25.0;

  //         // Update chart
  //         setState(() {
  //           if (chartData.length >= 20) chartData.removeAt(0);
  //           chartData.add(
  //             FlSpot(chartData.length.toDouble(), currentWaterLevel),
  //           );
  //         });
  //       }
  //     } else {
  //       debugPrint('Error fetching sensor: ${resp.statusCode}');
  //     }
  //   } catch (e) {
  //     debugPrint('Exception: $e');
  //   }
  // }
Future<void> _fetchLatestSensor() async {
  final data = await sensorService.fetchLatestSensor();
  if (data != null) {
    final distanceValue = data['distance'];
    if (distanceValue == null) {
      debugPrint('[Dashboard] ERROR: distance is null');
      return;
    }

    final double distanceCm = (distanceValue as num).toDouble();
    final double level = sensorService.convertDistanceToLevel(distanceCm);

    setState(() {
      this.distanceCm = distanceCm;
      currentWaterLevel = level;

      if (chartData.length >= 20) chartData.removeAt(0);
      chartData.add(
        FlSpot(chartData.length.toDouble(), currentWaterLevel),
      );
    });
  }
}


  void _showSafeLimitModal() {
    showDialog(
      context: context,
      barrierColor: AppColors.biruTua.withOpacity(0.8),
      builder: (context) => SafeLimitModal(
        currentLimit: safeLimit,
        onSave: (newLimit) {
          setState(() => safeLimit = newLimit);
        },
      ),
    );
  }

  void _resetChart() {
    setState(() {
      chartData = chartData.map((e) => FlSpot(e.x, 0)).toList();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool warning = currentWaterLevel > safeLimit;

    return Scaffold(
      backgroundColor: AppColors.biruTua,
      appBar: AppBar(
        title: const Text(
          'IoT Monitoring Air',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.biruMuda,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.biruPolarius),
            onPressed: _showSafeLimitModal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jarak: ${distanceCm.toStringAsFixed(1)} cm',
              style: const TextStyle(color: AppColors.putih),
            ),
            const SizedBox(height: 8),
            StatusCard(
              warning: warning,
              waterLevel: currentWaterLevel,
              glowController: _glowController,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(
                    child: WaterTankVisualization(
                      waterLevel: currentWaterLevel,
                      waveController: _waveController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RealtimeChart(
                      chartData: chartData,
                      safeLimit: safeLimit,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ControlPanel(
              onSetSafeLimit: _showSafeLimitModal,
              onReset: _resetChart,
            ),
          ],
        ),
      ),
    );
  }
}