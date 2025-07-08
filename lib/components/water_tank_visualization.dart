import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class WaterTankVisualization extends StatelessWidget {
  final double waterLevel;
  final AnimationController waveController;

  const WaterTankVisualization({
    Key? key,
    required this.waterLevel,
    required this.waveController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fillHeight = 260 * waterLevel / 100;
    
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 100,
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.biruPolarius, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          child: Container(
            width: 100,
            height: fillHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.biruPolarius.withOpacity(0.5),
                  AppColors.biruPolarius
                ],
              ),
            ),
            child: AnimatedBuilder(
              animation: waveController,
              builder: (context, _) => CustomPaint(
                painter: WavePainter(waveController.value, AppColors.biruPolarius),
                size: Size(100, fillHeight),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  WavePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.3);
    final path = Path()..moveTo(0, size.height * 0.5);
    
    for (double x = 0; x <= size.width; x++) {
      double y = sin((x / size.width * 2 * pi) + (progress * 2 * pi)) * 4 +
          size.height * 0.5;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}