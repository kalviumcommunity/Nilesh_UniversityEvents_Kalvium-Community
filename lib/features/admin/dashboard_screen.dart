import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../backend/syncsphere_backend.dart';
import '../../ui/avatar_circle.dart';
import '../../ui/stat_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onOpenEvents});

  /// Switches the admin shell to its Events tab.
  final VoidCallback? onOpenEvents;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<EventReport> _report;

  @override
  void initState() {
    super.initState();
    _report = SyncSphereBackend.instance.getEventReport();
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    final actions = <(IconData, String, VoidCallback)>[
      (
        Icons.add_box_outlined,
        'Create Event',
        () => nav.pushNamed(Routes.createEvent)
      ),
      (
        Icons.event_note_outlined,
        'Manage Events',
        () => widget.onOpenEvents?.call()
      ),
      (
        Icons.hub_outlined,
        'Assign Volunteers',
        () => widget.onOpenEvents?.call()
      ),
      (
        Icons.insert_chart_outlined,
        'View Reports',
        () => nav.pushNamed(Routes.reports)
      ),
    ];

    return Container(
      color: AppColors.navy,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: AvatarCircle(initial: 'N', size: 44),
            ),
            const SizedBox(height: 4),
            const Text(
              'Welcome Back,',
              style: TextStyle(color: Colors.white70, fontSize: 26),
            ),
            Text(
              SyncSphereBackend.instance.currentUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Event Coordinator',
              style: TextStyle(color: Colors.white60, fontSize: 18),
            ),
            const SizedBox(height: 26),
            FutureBuilder<EventReport>(
              future: _report,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Could not load dashboard statistics.',
                    style: TextStyle(color: Colors.white70),
                  );
                }
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                return Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        value: '${snapshot.data!.events}',
                        label: 'Events',
                        dark: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        value: '${snapshot.data!.registrations}',
                        label: 'Participants',
                        dark: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        value: '${snapshot.data!.volunteers}',
                        label: 'Assignments',
                        dark: true,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            for (final a in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColors.navyCard,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: a.$3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Icon(a.$1, color: Colors.white70, size: 26),
                          const SizedBox(width: 20),
                          Text(
                            a.$2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
