import 'package:flutter/material.dart';

class MyCafeteriaCard extends StatelessWidget {
  final VoidCallback onTap;

  const MyCafeteriaCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF8D6E63).withValues(alpha:0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E0D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_cafe,
                  size: 48,
                  color: Color(0xFF6D4C41),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Mi cafetería',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
