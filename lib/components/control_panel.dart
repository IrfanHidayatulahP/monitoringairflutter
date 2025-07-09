import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onSetSafeLimit;
  final VoidCallback onReset;

  const ControlPanel({
    Key? key,
    required this.onSetSafeLimit,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.biruMuda,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildControlButton(
              'Set Batas Aman',
              Icons.security,
              onSetSafeLimit,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildControlButton(
              'Reset',
              Icons.refresh,
              onReset,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.biruTua),
      label: Text(
        title,
        style: const TextStyle(
          color: AppColors.biruTua,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.biruPolarius,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}