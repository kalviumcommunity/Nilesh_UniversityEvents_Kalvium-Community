import 'package:flutter/material.dart';

import '../../app/app_role.dart';
import '../../app/routes.dart';
import '../../ui/app_button.dart';

class AllSetScreen extends StatelessWidget {
  const AllSetScreen({super.key, required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B2150), Color(0xFF0B1326), Color(0xFF0B1326)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE4E0FA), Color(0xFFA8A0D8)],
                    ),
                  ),
                  child: const Icon(Icons.check,
                      size: 84, color: Color(0xFF1B1F3A)),
                ),
                const SizedBox(height: 40),
                const Text(
                  "You're All Set!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  "Welcome to Nilesh\nLet's build a more connected\nand impactful campus.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70, fontSize: 18, height: 1.7),
                ),
                const Spacer(flex: 4),
                AppButton(
                  label: 'Go to Home',
                  style: AppButtonStyle.white,
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                    role == AppRole.student
                        ? Routes.studentHome
                        : Routes.adminHome,
                    (_) => false,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
