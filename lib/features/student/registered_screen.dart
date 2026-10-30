import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../ui/app_button.dart';

class RegisteredScreen extends StatelessWidget {
  const RegisteredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 230,
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(64),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFBEFE8), Color(0xFFE9EDFB)],
                  ),
                ),
                child: Transform.rotate(
                  angle: -0.5,
                  child: const Icon(
                    Icons.campaign_rounded,
                    size: 120,
                    color: Color(0xFF3F55C9),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "You're Registered!",
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'See you at the event.\nCheck your email for\ndetails and updates.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.muted, fontSize: 18, height: 1.7),
              ),
              const Spacer(flex: 3),
              AppButton(
                label: 'Add to Calendar',
                style: AppButtonStyle.outlined,
                icon: Icons.event_available_outlined,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Calendar export is not wired up yet.')),
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'View My Events',
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.studentHome,
                  (_) => false,
                  arguments: 2,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
