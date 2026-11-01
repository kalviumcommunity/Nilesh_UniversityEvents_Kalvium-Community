import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../data/mock_data.dart';
import '../../ui/app_button.dart';
import '../../ui/app_dropdown.dart';
import '../../ui/app_field.dart';
import '../../ui/image_placeholder.dart';
import '../../ui/screen_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.event});

  final MockEvent event;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _roles = ['Participant', 'Volunteer'];
  String _role = _roles.first;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
                title: 'Confirm Registration', showAvatar: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ImagePlaceholder(
                          colors: event.colors,
                          width: 100,
                          height: 100,
                          radius: 16,
                          icon: Icons.image_outlined,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                event.club,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Your Role',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppDropdown<String>(
                      hint: 'Select role',
                      value: _role,
                      items: _roles,
                      labelOf: (r) => r,
                      onChanged: (r) => setState(() => _role = r ?? _role),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const AppField(
                      hint: 'Any specific interests or questions?',
                      maxLines: 5,
                      fillColor: AppColors.greySoft,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: AppButton(
                label: 'Confirm',
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(Routes.registered),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
