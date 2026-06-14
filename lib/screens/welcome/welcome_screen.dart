import 'package:flutter/material.dart';

import '../auth/login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Spacer(),

              Icon(
                Icons.travel_explore,
                size: 120,
              ),

              const SizedBox(height: 30),

              const Text(
                'Welcome to SafarioX',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Explore the world with confidence',
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}