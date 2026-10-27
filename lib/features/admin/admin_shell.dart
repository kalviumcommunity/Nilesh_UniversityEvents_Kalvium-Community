import 'package:flutter/material.dart';

import '../../ui/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'manage_events_screen.dart';
import 'more_screen.dart';
import 'volunteers_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _items = [
    NavItem(Icons.home_outlined, 'Dashboard'),
    NavItem(Icons.add_box_outlined, 'Events'),
    NavItem(Icons.hub_outlined, 'Volunteers'),
    NavItem(Icons.menu, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(onOpenEvents: () => setState(() => _index = 1)),
          const ManageEventsScreen(),
          const VolunteersScreen(),
          const MoreScreen(),
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
