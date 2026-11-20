import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Stores circle-cropped group photos (REMARKS #145) in
/// `<app documents>/group_icons/`. The DB keeps only the file name, because
/// the absolute documents path can change between app updates (iOS).
///
/// [init] must be awaited once at startup so [fileFor] can resolve paths
/// synchronously while building widgets. Not supported on web (no file
/// system) — there [isSupported] is false and the UI hides photo options.
class GroupIconStorage {
  GroupIconStorage._();

  static const int iconSize = 256;
  static String? _dirPath;

  static bool get isSupported => !kIsWeb;

  static Future<void> init() async {
    if (!isSupported) return;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/group_icons');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dirPath = dir.path;
  }

  /// Test hook: point storage at a temp directory.
  @visibleForTesting
  static void setDirectoryForTesting(String path) => _dirPath = path;

  /// Resolves a stored file name; null if storage isn't ready or file missing.
  static File? fileFor(String? fileName) {
    if (fileName == null || _dirPath == null) return null;
    final f = File('$_dirPath/$fileName');
    return f.existsSync() ? f : null;
  }

  /// Downscales [imageBytes] to [iconSize]×[iconSize] PNG, saves it and
  /// returns the new file name.
  static Future<String> savePhoto(Uint8List imageBytes) async {
    final png = await downscaleToPng(imageBytes);
    return saveRaw(png);
  }

  /// Saves already-encoded PNG bytes (used by backup import) unchanged.
  static Future<String> saveRaw(Uint8List pngBytes) async {
    final dirPath = _dirPath;
    if (dirPath == null) throw StateError('GroupIconStorage not initialised');
    final name = 'g_${DateTime.now().microsecondsSinceEpoch}.png';
    await File('$dirPath/$name').writeAsBytes(pngBytes, flush: true);
    return name;
  }

  /// Deletes a stored photo; ignores missing files.
  static Future<void> delete(String? fileName) async {
    final f = fileFor(fileName);
    if (f != null) {
      try {
        await f.delete();
      } catch (_) {}
    }
  }

  static Future<Uint8List> downscaleToPng(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: iconSize,
      targetHeight: iconSize,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    codec.dispose();
    if (data == null) throw StateError('PNG encoding failed');
    return data.buffer.asUint8List();
  }
}
