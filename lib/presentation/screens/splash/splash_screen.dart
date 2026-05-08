import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Brief delay to ensure first frame is rendered with theme/locale available
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    // Fade in (200ms via AnimatedOpacity)
    setState(() => _opacity = 1.0);

    // Wait: 200ms fade-in completes + 500ms display hold
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Fade out (200ms via AnimatedOpacity)
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // Replace splash in nav stack — no back navigation possible to it
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUk = Localizations.localeOf(context).languageCode == 'uk';

    final bgColor      = isDark ? const Color(0xFF0F1117) : const Color(0xFFDDE4FF);
    final nameColor    = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
    final taglineColor = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 200),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with shadow + rounded corners
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                          alpha: isDark ? 0.4 : 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // App name
              Text(
                isUk ? 'Кошик' : 'Koshyk',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: nameColor,
                ),
              ),
              const SizedBox(height: 6),
              // Tagline
              Text(
                isUk ? 'рахує за тебе' : 'does the math for you',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: taglineColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
