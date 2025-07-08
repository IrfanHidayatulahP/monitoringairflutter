// lib/services/service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SensorService {
  final String baseUrl;

  SensorService({required this.baseUrl});

  Future<Map<String, dynamic>?> fetchLatestSensor() async {
    final url = Uri.parse('$baseUrl/sensor/get');
    debugPrint('[SensorService] Fetching sensor data from: $url');

    try {
      final resp = await http.get(url);
      debugPrint('[SensorService] Response status: ${resp.statusCode}');
      debugPrint('[SensorService] Raw body: ${resp.body}');

      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List;
        debugPrint('[SensorService] Decoded list: $list');

        if (list.isNotEmpty) {
          final data = list.first as Map<String, dynamic>;
          debugPrint('[SensorService] Latest sensor data: $data');

          if (!data.containsKey('distance') || data['distance'] == null) {
            debugPrint('[SensorService] ERROR: distance not found');
            return null;
          }

          return data;
        }
      } else {
        debugPrint('[SensorService] Failed to fetch sensor data.');
      }
    } catch (e) {
      debugPrint('[SensorService] Exception: $e');
    }

    return null;
  }

  /// Mengonversi distance ke level air berdasarkan kategori
  double convertDistanceToLevel(double distanceCm) {
    if (distanceCm <= 4) return 100.0; // full
    if (distanceCm <= 10) return 75.0;  // high
    if (distanceCm <= 15) return 50.0;  // medium
    if (distanceCm <= 18) return 25.0; // low
    return 0.0;                        // empty
  }
}
