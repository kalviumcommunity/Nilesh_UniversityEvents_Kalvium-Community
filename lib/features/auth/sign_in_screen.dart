import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../backend/syncsphere_backend.dart';
import '../../ui/app_button.dart';
import '../../ui/app_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() => _isSubmitting = true);

    final result = await SyncSphereBackend.instance.signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        result.user?.role == 'admin' || result.user?.role == 'coordinator'
            ? Routes.adminHome
            : Routes.studentHome,
        (_) => false,
      );
      return;
    }
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Sign in failed.')),
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email address first.')),
      );
      return;
    }
    try {
      await SyncSphereBackend.instance.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } on BackendException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

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
              AppField(
                hint: 'Email / University Email',
                icon: Icons.person_outline,
                dark: true,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 14),
              AppField(
                hint: 'Password',
                icon: Icons.lock_outline,
                dark: true,
                obscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: _isSubmitting ? 'Signing In...' : 'Sign In',
                style: AppButtonStyle.blue,
                onPressed: _isSubmitting ? null : _signIn,
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
