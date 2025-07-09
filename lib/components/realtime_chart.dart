import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../utils/constants.dart';

class RealtimeChart extends StatefulWidget {
  final List<FlSpot> chartData;
  final double safeLimit;

  const RealtimeChart({
    Key? key,
    required this.chartData,
    required this.safeLimit,
  }) : super(key: key);

  @override
  State<RealtimeChart> createState() => _RealtimeChartState();
}

class _RealtimeChartState extends State<RealtimeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<FlSpot> _previousData = [];
  List<FlSpot> _currentData = [];
  List<FlSpot> _interpolatedData = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Durasi transisi
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animation.addListener(() {
      setState(() {
        _interpolatedData = _interpolateData(_previousData, _currentData, _animation.value);
      });
    });
    
    _currentData = List.from(widget.chartData);
    _interpolatedData = List.from(_currentData);
  }

  @override
  void didUpdateWidget(RealtimeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Jika data berubah, lakukan animasi transisi
    if (_shouldAnimate(oldWidget.chartData, widget.chartData)) {
      _previousData = List.from(_currentData);
      _currentData = List.from(widget.chartData);
      
      _animationController.reset();
      _animationController.forward();
    } else {
      // Jika tidak perlu animasi, langsung update
      _currentData = List.from(widget.chartData);
      _interpolatedData = List.from(_currentData);
    }
  }

  bool _shouldAnimate(List<FlSpot> oldData, List<FlSpot> newData) {
    if (oldData.length != newData.length) return true;
    
    for (int i = 0; i < oldData.length; i++) {
      if ((oldData[i].y - newData[i].y).abs() > 0.1) {
        return true;
      }
    }
    return false;
  }

  List<FlSpot> _interpolateData(List<FlSpot> from, List<FlSpot> to, double t) {
    if (from.isEmpty) return to;
    if (to.isEmpty) return from;
    
    List<FlSpot> result = [];
    int maxLength = to.length;
    
    for (int i = 0; i < maxLength; i++) {
      double fromY = i < from.length ? from[i].y : (from.isNotEmpty ? from.last.y : 0);
      double toY = to[i].y;
      double fromX = i < from.length ? from[i].x : (from.isNotEmpty ? from.last.x : i.toDouble());
      double toX = to[i].x;
      
      double interpolatedY = fromY + (toY - fromY) * t;
      double interpolatedX = fromX + (toX - fromX) * t;
      
      result.add(FlSpot(interpolatedX, interpolatedY));
    }
    
    return result;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothChartPainter(_interpolatedData, widget.safeLimit),
      child: Container(),
    );
  }
}

class SmoothChartPainter extends CustomPainter {
  final List<FlSpot> data;
  final double safeLimit;

  SmoothChartPainter(this.data, this.safeLimit);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    _drawSafeLimitLine(canvas, size);
    _drawDataLine(canvas, size);
    _drawDataPoints(canvas, size);
  }

  void _drawSafeLimitLine(Canvas canvas, Size size) {
    final paintSafe = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    double ySafe = size.height * (1 - safeLimit / 100);
    
    // Gambar garis putus-putus untuk safe limit
    _drawDashedLine(canvas, Offset(0, ySafe), Offset(size.width, ySafe), paintSafe);
    
    // Tambahkan label safe limit
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Safe Limit: ${safeLimit.toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width - 10, ySafe - 15));
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final startOffset = start + (end - start) * (i * (dashWidth + dashSpace) / distance);
      final endOffset = start + (end - start) * ((i * (dashWidth + dashSpace) + dashWidth) / distance);
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  void _drawDataLine(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.biruPolarius
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    if (data.length < 2) return;
    
    Path path = Path();
    double span = size.width / (data.length - 1);
    
    // Gunakan cubic bezier untuk smooth curves
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      double x = span * i;
      double y = size.height * (1 - data[i].y / 100);
      points.add(Offset(x, y));
    }
    
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        if (i == 1) {
          // First curve
          Offset controlPoint = Offset(
            points[i-1].dx + (points[i].dx - points[i-1].dx) * 0.5,
            points[i-1].dy,
          );
          path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, points[i].dx, points[i].dy);
        } else {
          // Smooth curve between points
          Offset controlPoint1 = Offset(
            points[i-1].dx + (points[i].dx - points[i-1].dx) * 0.3,
            points[i-1].dy,
          );
          Offset controlPoint2 = Offset(
            points[i].dx - (points[i].dx - points[i-1].dx) * 0.3,
            points[i].dy,
          );
          path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, points[i].dx, points[i].dy);
        }
      }
    }
    
    canvas.drawPath(path, paintLine);
    
    // Tambahkan gradient fill area
    _drawGradientFill(canvas, size, path);
  }

  void _drawGradientFill(Canvas canvas, Size size, Path path) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.biruPolarius.withOpacity(0.3),
          AppColors.biruPolarius.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, gradientPaint);
  }

  void _drawDataPoints(Canvas canvas, Size size) {
    final paintPoint = Paint()
      ..color = AppColors.biruPolarius
      ..style = PaintingStyle.fill;
    
    final paintPointBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    double span = size.width / (data.length - 1);
    
    for (int i = 0; i < data.length; i++) {
      double x = span * i;
      double y = size.height * (1 - data[i].y / 100);
      
      // Gambar border putih
      canvas.drawCircle(Offset(x, y), 4, paintPointBorder);
      // Gambar titik data
      canvas.drawCircle(Offset(x, y), 3, paintPoint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SmoothChartPainter && 
           (oldDelegate.data != data || oldDelegate.safeLimit != safeLimit);
  }
}