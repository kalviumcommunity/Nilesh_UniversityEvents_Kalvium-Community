import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../backend/syncsphere_backend.dart';
import '../../data/app_models.dart';
import '../../ui/app_button.dart';
import '../../ui/avatar_circle.dart';
import '../../ui/event_row_card.dart';
import '../../ui/search_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _tabs = ['For You', 'Events', 'Clubs', 'Workshops'];
  int _tab = 0;

  void _openEvent(CampusEvent e) =>
      Navigator.of(context).pushNamed(Routes.eventDetails, arguments: e);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${SyncSphereBackend.instance.currentUserName} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                AvatarCircle(
                  initial: SyncSphereBackend.instance.currentUserName.isEmpty
                      ? '?'
                      : SyncSphereBackend.instance.currentUserName[0],
                  size: 46,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SearchBox(hint: 'Search events, clubs, people…', dark: true),
            const SizedBox(height: 20),
            Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 26),
                    child: GestureDetector(
                      onTap: () {
                        if (_tabs[i] == 'Clubs') {
                          Navigator.of(context).pushNamed(Routes.clubs);
                        } else {
                          setState(() => _tab = i);
                        }
                      },
                      child: Column(
                        children: [
                          Text(
                            _tabs[i],
                            style: TextStyle(
                              color: i == _tab ? Colors.white : Colors.white60,
                              fontSize: 17,
                              fontWeight:
                                  i == _tab ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 44,
                            height: 3,
                            color:
                                i == _tab ? Colors.white : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            StreamBuilder<List<CampusEvent>>(
              stream: SyncSphereBackend.instance.watchPublishedEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Could not load featured events.',
                    style: TextStyle(color: Colors.white70),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final featured = snapshot.data!.first;
                return Container(
                  height: 240,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B3A8F),
                        Color(0xFF6E5BC7),
                        Color(0xFF1F2A5E),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        featured.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        featured.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_available_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              featured.dateFull,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 150,
                        child: AppButton(
                          label: 'View Event',
                          style: AppButtonStyle.periwinkle,
                          height: 52,
                          onPressed: () => _openEvent(featured),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upcoming Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onViewAll,
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<CampusEvent>>(
              stream: SyncSphereBackend.instance.watchPublishedEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Could not load events.',
                    style: TextStyle(color: Colors.white70),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = snapshot.data!
                    .where((event) => event.status != 'Completed')
                    .take(3);
                return Column(
                  children: [
                    for (final event in events)
                      EventRowCard(
                        dark: true,
                        event: event,
                        lines: [
                          event.club,
                          '${event.dateShort} • ${event.place}'
                        ],
                        onTap: () => _openEvent(event),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
