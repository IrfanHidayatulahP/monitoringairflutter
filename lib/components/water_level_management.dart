// water_level_manager.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chart_data.dart';

class WaterLevelManager extends ChangeNotifier {
  double _currentLevel = 0;
  double _safeLimit = 80;
  List<FlSpot> _chartData = [];
  Timer? _dataTimer;
  
  // Smoothing parameters
  static const int _maxDataPoints = 50;
  static const double _smoothingFactor = 0.3; // 0.0 = no smoothing, 1.0 = maximum smoothing
  
  // Getters
  double get currentLevel => _currentLevel;
  double get safeLimit => _safeLimit;
  List<FlSpot> get chartData => _chartData;
  bool get isWarning => _currentLevel > _safeLimit;
  
  // Start data simulation (replace with your actual data source)
  void startDataCollection() {
    _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Simulate incoming data - replace with your actual data source
      _simulateIncomingData();
    });
  }
  
  void stopDataCollection() {
    _dataTimer?.cancel();
  }
  
  // Simulate incoming data - replace this with your actual data source
  void _simulateIncomingData() {
    // This is just for demonstration - replace with your actual data
    double newRawLevel = _currentLevel + ((-1 + 2 * (0.5)) * 5); // Random change
    newRawLevel = newRawLevel.clamp(0, 100);
    
    updateWaterLevel(newRawLevel);
  }
  
  // Update water level with smoothing
  void updateWaterLevel(double newLevel) {
    // Apply smoothing to reduce jerkiness
    double smoothedLevel = _currentLevel + (_smoothingFactor * (newLevel - _currentLevel));
    
    _currentLevel = smoothedLevel;
    
    // Update chart data
    _updateChartData(smoothedLevel);
    
    notifyListeners();
  }
  
  // Update chart data with new point
  void _updateChartData(double level) {
    double currentTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    
    _chartData.add(FlSpot(currentTime, level));
    
    // Keep only recent data points
    if (_chartData.length > _maxDataPoints) {
      _chartData.removeAt(0);
    }
    
    // Normalize x-axis for display
    _normalizeChartData();
  }
  
  // Normalize chart data for smooth display
  void _normalizeChartData() {
    if (_chartData.isEmpty) return;
    
    double minTime = _chartData.first.x;
    double maxTime = _chartData.last.x;
    double timeRange = maxTime - minTime;
    
    if (timeRange == 0) return;
    
    for (int i = 0; i < _chartData.length; i++) {
      double normalizedX = ((_chartData[i].x - minTime) / timeRange) * 100;
      _chartData[i] = FlSpot(normalizedX, _chartData[i].y);
    }
  }
  
  // Set safe limit
  void setSafeLimit(double limit) {
    _safeLimit = limit;
    notifyListeners();
  }
  
  // Reset data
  void resetData() {
    _currentLevel = 0;
    _chartData.clear();
    notifyListeners();
  }
  
  // Add manual data point (for testing or manual input)
  void addDataPoint(double level) {
    updateWaterLevel(level);
  }
  
  @override
  void dispose() {
    stopDataCollection();
    super.dispose();
  }
}

// Enhanced chart data model
class FlSpot {
  double x;
  final double y;

  FlSpot(this.x, this.y);
  
  @override
  String toString() => 'FlSpot($x, $y)';
}