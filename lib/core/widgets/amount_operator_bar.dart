import 'package:flutter/material.dart';

/// Row of arithmetic operator buttons shown directly above the system
/// keyboard while an amount field is focused (REMARKS #143).
///
/// Some keyboards (e.g. Samsung Keyboard in numeric mode) show no "+" / "−"
/// keys, so expressions like "300+450" could not be typed. This bar inserts
/// the operator at the cursor position of [controller], independent of the
/// device keyboard. Typographic symbols (× ÷ −) are inserted for readability;
/// `parseAmount` normalizes them to * / - before evaluating.
class AmountOperatorBar extends StatelessWidget {
  const AmountOperatorBar({super.key, required this.controller});

  final TextEditingController controller;

  static const operators = ['+', '−', '×', '÷'];

  void _insert(String op) {
    final text = controller.text;
    final sel = controller.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final newText = text.replaceRange(start, end, op);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + op.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // TextFieldTapRegion: taps on the bar count as taps "inside" the text
    // field, so the field keeps focus and the keyboard stays open.
    return TextFieldTapRegion(
      child: Material(
        color: scheme.surfaceContainerHigh,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            // ExcludeFocus: buttons never take focus away from the amount field.
            child: ExcludeFocus(
              child: Row(
                children: [
                  for (final op in operators)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          key: ValueKey('amount-op-$op'),
                          onPressed: () => _insert(op),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            side: BorderSide(color: scheme.outlineVariant),
                          ),
                          child: Text(
                            op,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
