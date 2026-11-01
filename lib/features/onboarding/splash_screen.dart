import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../backend/syncsphere_backend.dart';
import '../../app/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), _continue);
  }

  Future<void> _continue() async {
    try {
      final user = await SyncSphereBackend.instance.currentUser;
      if (!mounted) return;
      final destination = switch (user?.role) {
        'admin' || 'coordinator' => Routes.adminHome,
        'student' => Routes.studentHome,
        _ => Routes.onboarding,
      };
      Navigator.of(context).pushReplacementNamed(
        destination,
        arguments: destination == Routes.studentHome ? 0 : null,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Could not load your account.'),
        ),
      );
      Navigator.of(context).pushReplacementNamed(Routes.onboarding);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1326), Color(0xFF090F1F), Color(0xFF1B2766)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  colors: [Color(0xFF8E9BE8), Color(0xFF4A63C4)],
                ).createShader(rect),
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'SyncSphere',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'One Campus\nInfinite Possibilities',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white70, fontSize: 19, height: 1.4),
              ),
              const Spacer(flex: 6),
              const Text(
                'Clubs  •  Events  •  People',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
