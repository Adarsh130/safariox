import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'bottom_nav.dart';
import '../screens/admin/admin_nav.dart';
import '../config/app_config.dart';

class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  final UserService _userService = UserService();
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }
    try {
      role = await _userService.getUserRole(user.uid);
    } catch (e) {
      debugPrint('Error fetching role: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppConfig.primaryGreen),
        ),
      );
    }

    switch (role) {
      case 'admin':
        return const AdminNav();
      case 'user':
      default:
        return const BottomNav();
    }
  }
}
