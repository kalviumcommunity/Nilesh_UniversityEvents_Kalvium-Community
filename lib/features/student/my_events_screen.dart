import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../backend/syncsphere_backend.dart';
import '../../data/app_models.dart';
import '../../ui/event_row_card.dart';
import '../../ui/screen_header.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  bool _upcoming = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'My Events'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _Toggle(
                    label: 'Upcoming',
                    selected: _upcoming,
                    onTap: () => setState(() => _upcoming = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Toggle(
                    label: 'Past',
                    selected: !_upcoming,
                    onTap: () => setState(() => _upcoming = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<CampusEvent>>(
              stream: SyncSphereBackend.instance.watchMyEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load your registrations.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = snapshot.data!.where((event) {
                  final isPast = event.status == 'Completed';
                  return _upcoming ? !isPast : isPast;
                }).toList();
                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      _upcoming
                          ? 'No upcoming registrations'
                          : 'No past registrations',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: events.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.line),
                  itemBuilder: (context, i) {
                    final e = events[i];
                    void open() => Navigator.of(context)
                        .pushNamed(Routes.eventDetails, arguments: e);
                    return EventRowCard(
                      event: e,
                      lines: [
                        e.dateFull.replaceFirst(RegExp(r'^\w{3}, '), ''),
                        e.place,
                      ],
                      onTap: open,
                      action: GestureDetector(
                        onTap: open,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.greySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
