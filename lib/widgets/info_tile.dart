import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;

  final String label;

  final String value;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.grey.shade800,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white10),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.green.shade400, size: 28),

          const SizedBox(height: 10),

          Text(
            label,

            textAlign: TextAlign.center,

            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),

          const SizedBox(height: 6),

          Text(
            value,

            textAlign: TextAlign.center,

            overflow: TextOverflow.ellipsis,

            maxLines: 2,

            style: const TextStyle(
              color: Colors.white,

              fontWeight: FontWeight.bold,

              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
