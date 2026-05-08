import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kTutorialVersionKey = 'tutorial_version';
const _kNavTutorialSeenKey = 'tutorial_nav_seen';

class TutorialService {
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();
    final currentBuild = info.buildNumber;
    final lastSeen = prefs.getString(_kTutorialVersionKey);
    return lastSeen != currentBuild;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();
    await prefs.setString(_kTutorialVersionKey, info.buildNumber);
  }

  static Future<bool> shouldShowNavTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_kNavTutorialSeenKey) ?? false);
  }

  static Future<void> markNavTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNavTutorialSeenKey, true);
  }
}
