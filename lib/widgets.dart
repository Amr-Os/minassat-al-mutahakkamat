// Shared monochrome widgets: cards, buttons, section titles.

import 'package:flutter/material.dart';

import 'theme.dart';

class MonoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const MonoCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Mono.cardBg,
        border: Border.all(color: Mono.border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFFF0F0F0), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Mono.bright,
        foregroundColor: Mono.bg,
        disabledBackgroundColor: Mono.pressed,
        disabledForegroundColor: Mono.faint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const GhostButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFF0F0F0),
        disabledForegroundColor: const Color(0xFF5A5A5A),
        side: const BorderSide(color: Mono.borderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
