import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:university_events/app/theme.dart';
import 'package:university_events/features/auth/select_role_screen.dart';
import 'package:university_events/features/auth/sign_in_screen.dart';

void main() {
  testWidgets('sign in screen renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const SignInScreen()),
    );
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('select role screen lists the three roles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const SelectRoleScreen()),
    );
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Club Coordinator'), findsOneWidget);
    expect(find.text('Faculty / Admin'), findsOneWidget);
  });
}
