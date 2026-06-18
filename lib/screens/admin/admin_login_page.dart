import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import 'admin_nav.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final List<String> _enteredPin = [];
  bool _isError = false;

  void _onKeyPress(String key) {
    if (_enteredPin.length >= 6) return;
    setState(() {
      _enteredPin.add(key);
      _isError = false;
    });
    if (_enteredPin.length == 6) {
      _validatePin();
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() => _enteredPin.removeLast());
  }

  void _validatePin() {
    final pin = _enteredPin.join();
    if (pin == AppConfig.adminSecretPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminNav()),
      );
    } else {
      setState(() {
        _isError = true;
        _enteredPin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConfig.surfaceGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover),
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.6, 0.6)),
            const SizedBox(height: 20),
            Text('Admin Access',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppConfig.primaryGreen,
                      fontWeight: FontWeight.w700,
                    )).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            Text('Enter your 6-digit secure PIN',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppConfig.textGrey))
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 40),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _enteredPin.length
                        ? (_isError ? AppConfig.errorRed : AppConfig.primaryGreen)
                        : AppConfig.dividerColor,
                    border: Border.all(
                      color: _isError
                          ? AppConfig.errorRed
                          : (i < _enteredPin.length
                              ? AppConfig.primaryGreen
                              : AppConfig.textLight),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

            if (_isError) ...[
              const SizedBox(height: 12),
              Text(
                'Incorrect PIN. Try again.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppConfig.errorRed),
              ).animate().fadeIn(duration: 300.ms).shake(),
            ],

            const Spacer(),

            // Keypad
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Column(
                children: [
                  _buildKeyRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeyRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeyRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(child: _buildKey('0')),
                      Expanded(
                        child: GestureDetector(
                          onTap: _onDelete,
                          child: Container(
                            height: 64,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: AppConfig.surfaceGreen,
                              borderRadius:
                                  BorderRadius.circular(AppConfig.radiusMedium),
                            ),
                            child: const Icon(
                              Icons.backspace_outlined,
                              color: AppConfig.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      children: keys.map((k) => Expanded(child: _buildKey(k))).toList(),
    );
  }

  Widget _buildKey(String digit) {
    return GestureDetector(
      onTap: () => _onKeyPress(digit),
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: AppConfig.dividerColor),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Center(
          child: Text(
            digit,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppConfig.textDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
