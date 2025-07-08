import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../utils/constants.dart';

class RealtimeChart extends StatelessWidget {
  final List<FlSpot> chartData;
  final double safeLimit;

  const RealtimeChart({
    Key? key,
    required this.chartData,
    required this.safeLimit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChartPainter(chartData, safeLimit),
      child: Container(),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<FlSpot> data;
  final double safeLimit;

  ChartPainter(this.data, this.safeLimit);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    _drawSafeLimitLine(canvas, size);
    _drawDataLine(canvas, size);
  }

  void _drawSafeLimitLine(Canvas canvas, Size size) {
    final paintSafe = Paint()
      ..color = Colors.red
      ..strokeWidth = 1;
    double ySafe = size.height * (1 - safeLimit / 100);
    canvas.drawLine(Offset(0, ySafe), Offset(size.width, ySafe), paintSafe);
  }

  void _drawDataLine(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.biruPolarius
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    Path path = Path();
    double span = size.width / (data.length - 1);
    
    for (int i = 0; i < data.length; i++) {
      double x = span * i;
      double y = size.height * (1 - data[i].y / 100);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}