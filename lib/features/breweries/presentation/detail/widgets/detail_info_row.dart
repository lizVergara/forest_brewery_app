import 'package:flutter/material.dart';

class DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool selectable;

  const DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.selectable = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null || value!.trim().isEmpty
        ? 'Not available'
        : value!.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                if (selectable)
                  SelectableText(displayValue)
                else
                  Text(displayValue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
