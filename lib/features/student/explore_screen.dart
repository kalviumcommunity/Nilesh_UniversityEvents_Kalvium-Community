import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../data/mock_data.dart';
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

  List<MockEvent> get _visible {
    final type = _filters[_filter];
    return exploreEvents.where((e) {
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
    final events = _visible;
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
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      'No events found',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                  )
                : ListView.separated(
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
                  ),
          ),
        ],
      ),
    );
  }
}
