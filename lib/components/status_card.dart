import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusCard extends StatelessWidget {
  final bool warning;
  final double waterLevel;
  final AnimationController glowController;

  const StatusCard({
    Key? key,
    required this.warning,
    required this.waterLevel,
    required this.glowController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.biruMuda,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: warning ? Colors.red : AppColors.biruPolarius,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: glowController,
            builder: (context, _) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (warning ? Colors.red : AppColors.biruPolarius)
                    .withOpacity(0.2),
              ),
              child: Icon(
                warning ? Icons.warning : Icons.water_drop,
                color: warning ? Colors.red : AppColors.biruPolarius,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning ? 'PERINGATAN!' : 'NORMAL',
                  style: TextStyle(
                    color: warning ? Colors.red : AppColors.biruPolarius,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Level air ${'\u200B'}${'aman'}',
                  style: TextStyle(color: AppColors.putih, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${waterLevel.toStringAsFixed(0)}%',
            style: TextStyle(
              color: warning ? Colors.red : AppColors.biruPolarius,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}