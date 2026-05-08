import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Step indices: 0=Група, 1=Учасники, 2=Категорії
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep; // 0, 1 or 2
  const OnboardingProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final labels = [
      l.onboardingStepGroup,
      l.onboardingStepParticipants,
      l.onboardingStepCategories,
    ];
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            final done = stepIdx < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? cs.primary : cs.onSurface.withValues(alpha: 0.2),
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final done = stepIdx < currentStep;
          final active = stepIdx == currentStep;
          return _StepDot(
            label: labels[stepIdx],
            done: done,
            active: active,
            cs: cs,
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final ColorScheme cs;
  const _StepDot(
      {required this.label,
      required this.done,
      required this.active,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    final Color bg = (done || active) ? cs.primary : cs.onSurface.withValues(alpha: 0.15);
    final Color fg = (done || active) ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.4);
    final Color textCol = (done || active) ? cs.primary : cs.onSurface.withValues(alpha: 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Center(
            child: done
                ? Icon(Icons.check, size: 16, color: fg)
                : active
                    ? Icon(Icons.circle, size: 10, color: fg)
                    : Icon(Icons.circle_outlined, size: 10, color: fg),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: textCol)),
      ],
    );
  }
}
