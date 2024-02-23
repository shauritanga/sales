import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? backgroundIconColor;
  final String value;
  final Size size;
  const SummaryCard({
    super.key,
    this.title = "",
    this.icon,
    this.backgroundColor,
    this.iconColor,
    this.backgroundIconColor,
    required this.size,
    this.value = "",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: size.height * 0.15,
      width: size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0.5, 1),
                blurRadius: 0.5,
                spreadRadius: 1,
                color: Colors.grey)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(value),
          const SizedBox(height: 8),
          Flexible(child: Text(title)),
        ],
      ),
    );
  }
}
