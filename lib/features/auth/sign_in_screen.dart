import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../ui/app_button.dart';
import '../../ui/app_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 56),
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  colors: [Color(0xFF8E9BE8), Color(0xFF4A63C4)],
                ).createShader(rect),
                child: const Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Glad to see you again!',
                style: TextStyle(color: Colors.white70, fontSize: 17),
              ),
              const SizedBox(height: 44),
              const AppField(
                hint: 'Email / University Email',
                icon: Icons.person_outline,
                dark: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              const AppField(
                hint: 'Password',
                icon: Icons.lock_outline,
                dark: true,
                obscure: true,
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Sign In',
                style: AppButtonStyle.blue,
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.studentHome,
                  (_) => false,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'or continue with',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(child: _SocialTile(child: _GoogleMark())),
                  SizedBox(width: 14),
                  Expanded(
                    child: _SocialTile(
                      child: Icon(Icons.apple, color: Colors.white, size: 34),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(child: _SocialTile(child: _MicrosoftMark())),
                ],
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(Routes.signUp),
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account?  ",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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

class _SocialTile extends StatelessWidget {
  const _SocialTile({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navyBorder),
      ),
      child: child,
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 34,
          fontWeight: FontWeight.w800,
        ),
      );
}

class _MicrosoftMark extends StatelessWidget {
  const _MicrosoftMark();

  @override
  Widget build(BuildContext context) {
    Widget sq(Color c) => Container(width: 15, height: 15, color: c);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            sq(const Color(0xFFF25022)),
            const SizedBox(width: 3),
            sq(const Color(0xFF7FBA00))
          ],
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            sq(const Color(0xFF00A4EF)),
            const SizedBox(width: 3),
            sq(const Color(0xFFFFB900))
          ],
        ),
      ],
    );
  }
}
