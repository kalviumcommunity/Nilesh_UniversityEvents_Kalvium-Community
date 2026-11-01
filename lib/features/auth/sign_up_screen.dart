import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../backend/syncsphere_backend.dart';
import '../../ui/app_button.dart';
import '../../ui/app_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _agreed = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _isSubmitting = true);

    final result = await SyncSphereBackend.instance.signUp(
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: 'student',
      phone: _phoneController.text,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushNamed(Routes.selectRole);
      return;
    }

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Sign up failed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left, size: 32),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 28),
              const Text(
                'Create Account',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Join the Nilesh community',
                style: TextStyle(color: AppColors.muted, fontSize: 17),
              ),
              const SizedBox(height: 32),
              AppField(
                hint: 'Full Name',
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              AppField(
                hint: 'University Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 14),
              AppField(
                hint: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                controller: _phoneController,
              ),
              const SizedBox(height: 14),
              AppField(
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    activeColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                  ),
                  const Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(color: AppColors.muted),
                      children: [
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _isSubmitting ? 'Creating Account...' : 'Create Account',
                onPressed: _agreed && !_isSubmitting ? _signUp : null,
              ),
              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
