import 'package:flutter/material.dart';
import '../../../core/utils/pastel_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/split_hint.dart';

/// Light-blue chip under an expense row showing who shares a partially split
/// expense (REMARKS #149): coloured dot + name for up to 3 people, otherwise
/// "N of M participants". Used by the Expenses list and its share image.
class SplitHintChip extends StatelessWidget {
  final SplitHint hint;
  final Map<int, String> participantNames;
  final Map<int, Color> participantColors;
  final AppLocalizations l;

  const SplitHintChip({
    super.key,
    required this.hint,
    required this.participantNames,
    required this.participantColors,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? cs.primary : Color.lerp(cs.primary, Colors.black, 0.2)!;
    final bg = cs.primary.withValues(alpha: dark ? 0.18 : 0.09);
    final textStyle = TextStyle(fontSize: 12, color: fg, height: 1.2);

    final names = [
      for (final id in hint.receiverIds) participantNames[id] ?? '?',
    ];

    final Widget content;
    if (hint.showNames) {
      content = Wrap(
        spacing: 8,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < hint.receiverIds.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: participantColors[hint.receiverIds[i]] ??
                        kPastelColors[0],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(names[i],
                      style: textStyle, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
        ],
      );
    } else {
      content = Text(
        l.splitHintCount(hint.receiverIds.length, hint.groupSize),
        style: textStyle,
      );
    }

    return Semantics(
      label: l.splitHintSemantics(names.join(', ')),
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group, size: 14, color: fg),
            const SizedBox(width: 5),
            Flexible(child: content),
          ],
        ),
      ),
    );
  }
}
