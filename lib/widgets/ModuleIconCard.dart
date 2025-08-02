import 'package:flutter/material.dart';

class ModuleIconCard extends StatelessWidget {
  final String moduleName;

  const ModuleIconCard({super.key, required this.moduleName});

  String get _iconPath {
    // Convert name to lowercase and replace spaces
    return 'assets/images/icons/${moduleName.toLowerCase().replaceAll(' ', '_')}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              _iconPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.apps, // fallback icon
                    color: Colors.white,
                    size: 36,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          moduleName,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
