import 'package:flutter/material.dart';

/// Honest placeholder: says clearly that the feature is not built yet.
class PlannedFeaturePage extends StatelessWidget {
  const PlannedFeaturePage({
    super.key,
    required this.title,
    required this.icon,
    required this.step,
    required this.description,
  });

  final String title;
  final IconData icon;
  final int step;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Chip(label: Text('Not built yet. Planned for Step $step.')),
          ],
        ),
      ),
    );
  }
}
