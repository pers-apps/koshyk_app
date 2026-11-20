import 'package:flutter/material.dart';

import '../../features/groups/data/group_icon_storage.dart';

/// Circular group icon (REMARKS #145).
/// Priority: photo → emoji → coloured circle with the first letter of [name].
class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    super.key,
    required this.name,
    this.iconEmoji,
    this.iconImage,
    this.size = 40,
  });

  final String name;
  final String? iconEmoji;
  final String? iconImage;
  final double size;

  static const _palette = <Color>[
    Color(0xFF5C6BC0), Color(0xFF26A69A), Color(0xFFEF6C00), Color(0xFF8E24AA),
    Color(0xFF43A047), Color(0xFFD81B60), Color(0xFF1E88E5), Color(0xFF6D4C41),
  ];

  /// Stable colour per group name.
  static Color colorFor(String name) {
    var h = 0;
    for (final c in name.trim().toLowerCase().runes) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return _palette[h % _palette.length];
  }

  static String initialOf(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return String.fromCharCode(t.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final file = GroupIconStorage.fileFor(iconImage);
    if (file != null) {
      return ClipOval(
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Re-read when a photo is replaced under the same widget.
          key: ValueKey(iconImage),
          errorBuilder: (_, __, ___) => _letter(context),
        ),
      );
    }
    final emoji = iconEmoji?.trim();
    if (emoji != null && emoji.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Text(emoji, style: TextStyle(fontSize: size * 0.55, height: 1)),
      );
    }
    return _letter(context);
  }

  Widget _letter(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: colorFor(name)),
        child: Text(
          initialOf(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      );
}
