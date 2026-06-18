import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';
import '../../widgets/role_gate.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String verificationId;

  const OtpPage({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final UserService _userService = UserService();
  bool isLoading = false;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
        }
      });
      return _resendSeconds > 0;
    });
  }

  String get _otpValue =>
      _controllers.map((c) => c.text).join();

  Future<void> verifyOtp() async {
    if (_otpValue.length < 6) {
      _showSnack('Please enter all 6 digits');
      return;
    }
    setState(() => isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpValue,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        final existing = await _userService.getUser(userId);
        if (existing == null) {
          await _userService.createUser(AppUser(
            uid: userId,
            fullName: userCredential.user!.displayName ?? '',
            phone: widget.phone,
            email: userCredential.user!.email ?? '',
            role: 'user',
            profileImage: '',
            isActive: true,
          ));
        }
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RoleGate()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message ?? 'Invalid OTP. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppConfig.primaryGreen,
            ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppConfig.surfaceGreen,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConfig.dividerColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppConfig.primaryGreen, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConfig.dividerColor, width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && val.isNotEmpty) {
            verifyOtp();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                gradient: AppConfig.darkGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(
                    'Verify OTP',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to\n${widget.phone}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                children: [
                  // OTP fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => _buildOtpField(i)),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  const SizedBox(height: 32),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : verifyOtp,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Verify & Continue',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // Resend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppConfig.textGrey),
                      ),
                      _canResend
                          ? TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Text('Resend',
                                  style: TextStyle(
                                      color: AppConfig.primaryGreen,
                                      fontWeight: FontWeight.w600)),
                            )
                          : Text(
                              'Resend in ${_resendSeconds}s',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppConfig.primaryGreen,
                                      fontWeight: FontWeight.w600),
                            ),
                    ],
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                    label: const Text('Change Number'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConfig.textGrey,
                    ),
                  ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
