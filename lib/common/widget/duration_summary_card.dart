import 'package:flutter/material.dart';
import 'package:time_tracker/common/time_util.dart';

class DurationSummaryCard extends StatelessWidget {
  final Duration duration;
  final String label;

  const DurationSummaryCard({
    super.key,
    required this.duration,
    this.label = 'Gesamtdauer:',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              toDurationHoursAndMinutes(duration),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
