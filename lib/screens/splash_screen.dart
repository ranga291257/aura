import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final onboarded = await StorageService.isOnboarded();
    final profile = onboarded ? await StorageService.loadProfile() : null;
    if (!mounted) return;

    final showHome = onboarded && profile != null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => showHome ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepInk,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✦',
                style: TextStyle(
                  fontSize: 32,
                  color: AppTheme.cream.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AURA',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.cream,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'YOUR DAILY COSMIC GUIDE',
                style: GoogleFonts.lato(
                  fontSize: 9,
                  color: AppTheme.cream.withOpacity(0.35),
                  letterSpacing: 4.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
