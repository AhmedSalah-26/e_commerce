import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? sub;
  final Color color;
  final bool isMobile;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.sub,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 28 : 32),
            ),
            SizedBox(width: isMobile ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub!,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: color,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
