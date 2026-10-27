import 'package:flutter/material.dart';

import '../../ui/bottom_nav.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'my_events_screen.dart';
import 'profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late int _index = widget.initialTab;

  static const _items = [
    NavItem(Icons.home_outlined, 'Home'),
    NavItem(Icons.search, 'Explore'),
    NavItem(Icons.event_available_outlined, 'My Events'),
    NavItem(Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onViewAll: () => setState(() => _index = 1)),
          const ExploreScreen(),
          const MyEventsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: _index,
        dark: _index == 0,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
