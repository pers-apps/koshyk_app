import 'package:flutter/material.dart';

/// Scaffold з градієнтним фоном для light/dark теми.
/// Використовувати замість звичайного Scaffold на всіх основних екранах.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  static const _lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDDE4FF), Color(0xFFCCF2E4)],
  );

  static const _darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F1117), Color(0xFF1A1F35)],
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark ? _darkGradient : _lightGradient,
          ),
          child: body,
        ),
      ),
    );
  }
}
