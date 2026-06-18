import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../auth/login_page.dart';
import '../admin/admin_login_page.dart';
import '../../widgets/role_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const RoleGate() : const LoginPage(),
      ),
    );
  }

  void _onLogoTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) > const Duration(seconds: 3)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;

    if (_tapCount >= 5) {
      _tapCount = 0;
      // Navigate to hidden admin login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppConfig.darkGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo
              GestureDetector(
                onTap: _onLogoTap,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.6, 0.6), duration: 600.ms, curve: Curves.elasticOut),
              ),
              const SizedBox(height: 28),
              // App Name
              Text(
                'SafariOX India',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms),
              const SizedBox(height: 10),
              // Tagline
              Text(
                AppConfig.appTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.3,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms),
              const Spacer(flex: 2),
              // Loading indicator
              Column(
                children: [
                  SizedBox(
                    width: 140,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preparing your journey...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}