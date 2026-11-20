import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../data/group_icon_storage.dart';

/// Result of the group icon picker (REMARKS #145).
sealed class GroupIconChoice {
  const GroupIconChoice();
}

class GroupIconEmoji extends GroupIconChoice {
  const GroupIconEmoji(this.emoji);
  final String emoji;
}

/// A new photo already cropped, downscaled and saved to [GroupIconStorage].
class GroupIconPhoto extends GroupIconChoice {
  const GroupIconPhoto(this.fileName);
  final String fileName;
}

class GroupIconRemove extends GroupIconChoice {
  const GroupIconRemove();
}

const _suggestedEmojis = [
  '🏖️', '✈️', '🏔️', '🏕️', '🚗', '🚆', '🏠', '🏡',
  '🎉', '🎂', '🍕', '🍽️', '🍻', '☕', '🛒', '🎁',
  '⚽', '🎮', '🎵', '🎓', '💼', '👨‍👩‍👧', '❤️', '⭐',
];

/// Opens the bottom sheet; returns null if dismissed.
Future<GroupIconChoice?> showGroupIconPicker(
  BuildContext context, {
  required bool hasIcon,
}) async {
  final l = AppLocalizations.of(context)!;
  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.emoji_emotions_outlined),
            title: Text(l.groupIconEmoji),
            onTap: () => Navigator.pop(ctx, 'emoji'),
          ),
          if (GroupIconStorage.isSupported) ...[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.groupIconGallery),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.groupIconCamera),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
          ],
          if (hasIcon)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l.groupIconRemove),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return null;

  switch (action) {
    case 'emoji':
      final e = await _pickEmoji(context);
      return e == null ? null : GroupIconEmoji(e);
    case 'remove':
      return const GroupIconRemove();
    case 'gallery':
    case 'camera':
      return _pickPhoto(
        context,
        action == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
  }
  return null;
}

Future<String?> _pickEmoji(BuildContext context) {
  final l = AppLocalizations.of(context)!;
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.groupIconEmoji),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final e in _suggestedEmojis)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pop(ctx, e),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(e, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(labelText: l.groupIconEmojiHint),
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () {
            final t = ctrl.text.trim();
            Navigator.pop(ctx, t.isEmpty ? null : t.characters.first);
          },
          child: Text(l.done),
        ),
      ],
    ),
  );
}

Future<GroupIconChoice?> _pickPhoto(
    BuildContext context, ImageSource source) async {
  final l = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  try {
    // Pre-shrink large camera shots so cropping stays fast.
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null || !context.mounted) return null;
    final bytes = await picked.readAsBytes();
    if (!context.mounted) return null;
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _CircleCropScreen(image: bytes),
      ),
    );
    if (cropped == null) return null;
    final name = await GroupIconStorage.savePhoto(cropped);
    return GroupIconPhoto(name);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l.groupIconError)));
    return null;
  }
}

/// Full-screen editor with a circular crop frame; pops the cropped bytes.
class _CircleCropScreen extends StatefulWidget {
  const _CircleCropScreen({required this.image});
  final Uint8List image;

  @override
  State<_CircleCropScreen> createState() => _CircleCropScreenState();
}

class _CircleCropScreenState extends State<_CircleCropScreen> {
  final _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l.groupIconCropTitle),
        actions: [
          TextButton(
            onPressed: _cropping
                ? null
                : () {
                    setState(() => _cropping = true);
                    _controller.cropCircle();
                  },
            child: Text(l.done),
          ),
        ],
      ),
      body: Stack(
        children: [
          Crop(
            image: widget.image,
            controller: _controller,
            withCircleUi: true,
            interactive: true,
            baseColor: Colors.black,
            maskColor: Colors.black.withValues(alpha: 0.6),
            progressIndicator:
                const Center(child: CircularProgressIndicator()),
            onCropped: (result) {
              switch (result) {
                case CropSuccess(:final croppedImage):
                  Navigator.pop(context, croppedImage);
                case CropFailure():
                  setState(() => _cropping = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.groupIconError)));
              }
            },
          ),
          if (_cropping)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
