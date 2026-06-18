import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'modules/admin_dashboard.dart';
import 'modules/create_trip_page.dart';
import 'modules/student_list_page.dart';
import 'modules/payment_report_page.dart';
import 'modules/generate_reports_page.dart';

class AdminNav extends StatefulWidget {
  const AdminNav({super.key});

  @override
  State<AdminNav> createState() => _AdminNavState();
}

class _AdminNavState extends State<AdminNav> {
  int _currentIndex = 0;

  final _pages = const [
    AdminDashboardScreen(),
    CreateTripPage(),
    StudentListPage(),
    PaymentReportPage(),
    GenerateReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafariOX Admin'),
        backgroundColor: AppConfig.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Exit Admin',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Exit Admin Panel'),
                  content:
                      const Text('Return to regular user view?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Exit')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'New Trip',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
