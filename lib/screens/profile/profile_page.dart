import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../models/app_user.dart';
import '../../services/user_service.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();
  AppUser? _appUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final appUser = await _userService.getUser(user.uid);
    if (mounted) {
      setState(() {
        _appUser = appUser;
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: AppConfig.errorRed))),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppConfig.bgWhite,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppConfig.primaryGreen))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      bottom: 32,
                    ),
                    decoration: const BoxDecoration(
                      gradient: AppConfig.darkGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Text(
                                  (_appUser?.fullName.isNotEmpty ?? false)
                                      ? _appUser!.fullName[0].toUpperCase()
                                      : 'S',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: Colors.white))
                              : null,
                        ).animate().scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        Text(
                          _appUser?.fullName.isNotEmpty ?? false
                              ? _appUser!.fullName
                              : (user?.displayName ?? 'Student'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.white),
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        const SizedBox(height: 4),
                        Text(
                          _appUser?.phone.isNotEmpty ?? false
                              ? _appUser!.phone
                              : (user?.email ?? ''),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8)),
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_appUser?.joinedTrips.length ?? 0} Trips Joined',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.person_outline_rounded,
                          title: 'Personal Information',
                          subtitle: 'Name, phone, email',
                          onTap: () {},
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                        _settingsTile(
                          context,
                          icon: Icons.tour_rounded,
                          title: 'My Trips',
                          subtitle: '${_appUser?.joinedTrips.length ?? 0} trips',
                          onTap: () {},
                        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                        _settingsTile(
                          context,
                          icon: Icons.notifications_outlined,
                          title: 'Notification Settings',
                          subtitle: 'Manage trip alerts',
                          onTap: () {},
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                        _settingsTile(
                          context,
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'FAQs and contact us',
                          onTap: () {},
                        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                        _settingsTile(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Terms of service',
                          onTap: () {},
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout_rounded,
                                color: AppConfig.errorRed),
                            label: const Text('Sign Out',
                                style:
                                    TextStyle(color: AppConfig.errorRed)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppConfig.errorRed),
                            ),
                          ),
                        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                        const SizedBox(height: 16),
                        Text(
                          '${AppConfig.appName} v${AppConfig.appVersion}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppConfig.textLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          border: Border.all(color: AppConfig.dividerColor),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConfig.surfaceGreen,
                borderRadius: BorderRadius.circular(AppConfig.radiusSmall),
              ),
              child: Icon(icon, color: AppConfig.primaryGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppConfig.textGrey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppConfig.textLight),
          ],
        ),
      ),
    );
  }
}
