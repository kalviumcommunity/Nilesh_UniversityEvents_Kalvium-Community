import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../backend/syncsphere_backend.dart';
import '../../data/app_models.dart';
import '../../ui/chip_row.dart';
import '../../ui/screen_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _filters = ['All', 'Events', 'Mentions'];
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Notifications'),
            ChipRow(
              labels: _filters,
              selected: _filter,
              onSelected: (i) => setState(() => _filter = i),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<UserNotification>>(
                stream: SyncSphereBackend.instance.watchNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Could not load notifications.'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final f = _filters[_filter];
                  final items = snapshot.data!
                      .where((n) => f == 'All' || n.type == f)
                      .toList();
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nothing here yet',
                        style: TextStyle(color: AppColors.muted, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.line),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: n.tint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.ink,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.body,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (n.time.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      n.time,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.muted),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
