import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';
import '../../widgets/role_gate.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserService _userService = UserService();
  final phoneController = TextEditingController();
  bool isLoading = false;
  bool isGoogleLoading = false;

  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isGoogleLoading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        final existingUser = await _userService.getUser(userId);
        if (existingUser == null) {
          await _userService.createUser(AppUser(
            uid: userId,
            fullName: userCredential.user!.displayName ?? '',
            phone: '',
            email: userCredential.user!.email ?? '',
            role: 'user',
            profileImage: userCredential.user!.photoURL ?? '',
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
    } catch (e) {
      if (!mounted) return;
      _showSnack('Google Sign-In failed. Please try again.');
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.length != 10) {
      _showSnack('Please enter a valid 10-digit mobile number');
      return;
    }
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) _showSnack('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpPage(
                phone: '+91$phone',
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error sending OTP. Please try again.');
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
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top gradient header
            Container(
              height: size.height * 0.38,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppConfig.darkGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover),
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.7, 0.7)),
                    const SizedBox(height: 16),
                    Text(
                      'SafariOX India',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 6),
                    Text(
                      AppConfig.appTagline,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
            // Login Form
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back 👋',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to manage your educational trips',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConfig.textGrey,
                        ),
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
                  const SizedBox(height: 28),

                  // Phone Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConfig.radiusMedium),
                      border: Border.all(color: AppConfig.dividerColor, width: 1.5),
                      boxShadow: AppConfig.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                  color: AppConfig.dividerColor, width: 1.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 6),
                              Text(
                                '+91',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'Enter mobile number',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              counterText: '',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppConfig.textLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  const SizedBox(height: 16),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConfig.radiusMedium),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Send OTP',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppConfig.textGrey)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // Google Sign-In
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: isGoogleLoading ? null : signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppConfig.dividerColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConfig.radiusMedium),
                        ),
                      ),
                      child: isGoogleLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: AppConfig.primaryGreen,
                                  strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                                  width: 22,
                                  height: 22,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.g_mobiledata, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Sign in with Google',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppConfig.textDark),
                                ),
                              ],
                            ),
                    ),
                  ).animate().fadeIn(delay: 650.ms, duration: 400.ms),

                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppConfig.textLight),
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
