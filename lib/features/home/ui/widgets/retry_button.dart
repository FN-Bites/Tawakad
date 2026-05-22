import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback onTap;

  const RetryButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F8EFA),
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Text(
          'إعادة المحاولة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
