import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../backend/syncsphere_backend.dart';
import '../../data/app_models.dart';
import '../../ui/chip_row.dart';
import '../../ui/event_row_card.dart';
import '../../ui/screen_header.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  static const _filters = ['All', 'Draft', 'Ongoing', 'Completed'];
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final f = _filters[_filter];

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'My Events'),
          ChipRow(
            labels: _filters,
            selected: _filter,
            onSelected: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<CampusEvent>>(
              stream: SyncSphereBackend.instance.watchManagedEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load managed events.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = snapshot.data!
                    .where((event) => f == 'All' || event.status == f)
                    .toList();
                if (events.isEmpty) {
                  return const Center(
                    child: Text(
                      'No events in this state',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
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
                    return EventRowCard(
                      event: e,
                      lines: [
                        e.dateFull.replaceFirst(RegExp(r'^\w{3}, '), ''),
                        e.place,
                      ],
                      onTap: () => Navigator.of(context).pushNamed(
                        Routes.assignVolunteers,
                        arguments: e,
                      ),
                      action: _StatusPill(e.status),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Ongoing' => (AppColors.greenSoft, AppColors.green),
      'Upcoming' => (AppColors.blueSoft, AppColors.blue),
      'Draft' => (AppColors.orangeSoft, AppColors.orange),
      _ => (AppColors.greySoft, AppColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
