import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SafeLimitModal extends StatefulWidget {
  final double currentLimit;
  final Function(double) onSave;

  const SafeLimitModal({
    Key? key,
    required this.currentLimit,
    required this.onSave,
  }) : super(key: key);

  @override
  _SafeLimitModalState createState() => _SafeLimitModalState();
}

class _SafeLimitModalState extends State<SafeLimitModal> {
  late double tempLimit;

  @override
  void initState() {
    super.initState();
    tempLimit = widget.currentLimit;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.biruMuda,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.biruPolarius, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Batas Aman',
              style: TextStyle(
                color: AppColors.putih,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: tempLimit,
              min: 0,
              max: 100,
              divisions: 4,
              label: '${tempLimit.toStringAsFixed(0)}%',
              activeColor: AppColors.biruPolarius,
              onChanged: (value) {
                setState(() {
                  tempLimit = value;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.biruMuda,
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: AppColors.putih),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(tempLimit);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.biruPolarius,
                      foregroundColor: AppColors.biruTua,
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}