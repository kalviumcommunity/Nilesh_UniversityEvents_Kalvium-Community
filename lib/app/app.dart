import 'package:flutter/material.dart';

import '../data/app_models.dart';
import '../features/admin/admin_shell.dart';
import '../features/admin/assign_volunteers_screen.dart';
import '../features/admin/create_event_screen.dart';
import '../features/admin/reports_screen.dart';
import '../features/auth/all_set_screen.dart';
import '../features/auth/select_role_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/common/notifications_screen.dart';
import '../features/common/settings_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/student/clubs_screen.dart';
import '../features/student/event_details_screen.dart';
import '../features/student/my_events_screen.dart';
import '../features/student/register_screen.dart';
import '../features/student/registered_screen.dart';
import '../features/student/student_shell.dart';
import 'app_role.dart';
import 'routes.dart';
import 'theme.dart';

class SyncSphereApp extends StatelessWidget {
  const SyncSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncSphere',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: Routes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

Route<void> _onGenerateRoute(RouteSettings settings) {
  Route<void> page(Widget child) =>
      MaterialPageRoute<void>(builder: (_) => child, settings: settings);

  final args = settings.arguments;
  switch (settings.name) {
    case Routes.onboarding:
      return page(const OnboardingScreen());
    case Routes.signIn:
      return page(const SignInScreen());
    case Routes.signUp:
      return page(const SignUpScreen());
    case Routes.selectRole:
      return page(const SelectRoleScreen());
    case Routes.allSet:
      return page(AllSetScreen(role: args is AppRole ? args : AppRole.student));
    case Routes.studentHome:
      return page(StudentShell(initialTab: args is int ? args : 0));
    case Routes.adminHome:
      return page(const AdminShell());
    case Routes.eventDetails:
      return args is CampusEvent
          ? page(EventDetailsScreen(event: args))
          : page(const _MissingEventScreen());
    case Routes.register:
      return args is CampusEvent
          ? page(RegisterScreen(event: args))
          : page(const _MissingEventScreen());
    case Routes.registered:
      return page(const RegisteredScreen());
    case Routes.myEvents:
      return page(const MyEventsScreen());
    case Routes.clubs:
      return page(const ClubsScreen());
    case Routes.settings:
      return page(const SettingsScreen());
    case Routes.notifications:
      return page(const NotificationsScreen());
    case Routes.createEvent:
      return page(const CreateEventScreen());
    case Routes.assignVolunteers:
      return args is CampusEvent
          ? page(AssignVolunteersScreen(event: args))
          : page(const _MissingEventScreen());
    case Routes.reports:
      return page(const ReportsScreen());
    case Routes.splash:
    default:
      return page(const SplashScreen());
  }
}

class _MissingEventScreen extends StatelessWidget {
  const _MissingEventScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('This event could not be found.')),
      );
}
