import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../backend/syncsphere_backend.dart';
import '../../data/app_models.dart';
import '../../ui/chip_row.dart';
import '../../ui/event_row_card.dart';
import '../../ui/screen_header.dart';
import '../../ui/search_box.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _filters = ['All', 'Events', 'Clubs', 'Workshops'];
  int _filter = 0;
  String _query = '';

  List<CampusEvent> _visible(List<CampusEvent> events) {
    final type = _filters[_filter];
    return events.where((e) {
      final matchesType = type == 'All' || e.type == type;
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.club.toLowerCase().contains(q);
      return matchesType && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'Explore'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchBox(
              hint: 'Search events, clubs...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 16),
          ChipRow(
            labels: _filters,
            selected: _filter,
            onSelected: (i) {
              if (_filters[i] == 'Clubs') {
                Navigator.of(context).pushNamed(Routes.clubs);
              } else {
                setState(() => _filter = i);
              }
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<CampusEvent>>(
              stream: SyncSphereBackend.instance.watchPublishedEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load events. Please try again.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = _visible(snapshot.data!);
                if (events.isEmpty) {
                  return const Center(
                    child: Text(
                      'No events found',
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
                      lines: [e.club, '${e.dateShort} • ${e.place}'],
                      onTap: () => Navigator.of(context)
                          .pushNamed(Routes.eventDetails, arguments: e),
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
