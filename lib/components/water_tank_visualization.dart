// water_tank_visualization.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class WaterTankVisualization extends StatefulWidget {
  final double waterLevel;
  final AnimationController waveController;

  const WaterTankVisualization({
    Key? key,
    required this.waterLevel,
    required this.waveController,
  }) : super(key: key);

  @override
  _WaterTankVisualizationState createState() => _WaterTankVisualizationState();
}

class _WaterTankVisualizationState extends State<WaterTankVisualization>
    with SingleTickerProviderStateMixin {
  static const double TANK_HEIGHT = 260.0; // Konstanta untuk tinggi yang sama
  
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  double _previousLevel = 0;

  @override
  void initState() {
    super.initState();
    _levelController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _levelAnimation = Tween<double>(
      begin: 0,
      end: widget.waterLevel,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut,
    ));
    
    _previousLevel = widget.waterLevel;
    _levelController.forward();
  }

  @override
  void didUpdateWidget(WaterTankVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waterLevel != widget.waterLevel) {
      _animateToNewLevel(widget.waterLevel);
    }
  }

  void _animateToNewLevel(double newLevel) {
    _levelAnimation = Tween<double>(
      begin: _previousLevel,
      end: newLevel,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut,
    ));
    
    _previousLevel = newLevel;
    _levelController.reset();
    _levelController.forward();
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _levelAnimation,
      builder: (context, child) {
        final double animatedLevel = _levelAnimation.value;
        final double fillHeight = TANK_HEIGHT * animatedLevel / 100;
        
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Tank Container
            Container(
              width: 100,
              height: TANK_HEIGHT,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.biruPolarius, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Water Fill
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
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
                  animation: widget.waveController,
                  builder: (context, _) => CustomPaint(
                    painter: WavePainter(
                      widget.waveController.value,
                      AppColors.biruPolarius,
                      animatedLevel,
                    ),
                    size: Size(100, fillHeight),
                  ),
                ),
              ),
            ),
            // Level Indicator
            Positioned(
              right: 110,
              bottom: fillHeight - 10,
              child: AnimatedOpacity(
                opacity: animatedLevel > 5 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                // child: Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: AppColors.biruPolarius,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     '${animatedLevel.toStringAsFixed(0)}%',
                //     style: const TextStyle(
                //       color: AppColors.biruTua,
                //       fontSize: 12,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double waterLevel;

  WavePainter(this.progress, this.color, this.waterLevel);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0) return;

    final paint = Paint()..color = color.withOpacity(0.3);
    final path = Path();
    
    // Create wave effect
    final waveHeight = size.height > 20 ? 4.0 : size.height * 0.2;
    final waveFrequency = 2.0;
    final waveSpeed = progress * 2 * pi;
    
    path.moveTo(0, size.height * 0.5);
    
    for (double x = 0; x <= size.width; x += 1) {
      double y = sin((x / size.width * waveFrequency * pi) + waveSpeed) * waveHeight +
          size.height * 0.5;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add subtle secondary wave
    final paint2 = Paint()..color = color.withOpacity(0.2);
    final path2 = Path();
    
    path2.moveTo(0, size.height * 0.3);
    
    for (double x = 0; x <= size.width; x += 1) {
      double y = sin((x / size.width * waveFrequency * pi) + waveSpeed + pi/3) * (waveHeight * 0.7) +
          size.height * 0.3;
      path2.lineTo(x, y);
    }
    
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}