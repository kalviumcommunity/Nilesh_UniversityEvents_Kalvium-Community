import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../backend/syncsphere_backend.dart';
import '../../ui/avatar_circle.dart';
import '../../ui/chip_row.dart';
import '../../ui/screen_header.dart';
import '../../ui/search_box.dart';

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  static const _filters = ['All', 'Students'];
  int _filter = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'Student Volunteers'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchBox(
              hint: 'Search volunteers...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 16),
          ChipRow(
            labels: _filters,
            selected: _filter,
            onSelected: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: SyncSphereBackend.instance.watchStudentDirectory(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load student volunteers.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final visible = snapshot.data!
                    .where((user) =>
                        q.isEmpty || user.name.toLowerCase().contains(q))
                    .toList();
                if (visible.isEmpty) {
                  return const Center(
                    child: Text(
                      'No student volunteers found',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.line),
                  itemBuilder: (context, i) {
                    final v = visible[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          AvatarCircle(
                            initial: v.name.isEmpty ? '?' : v.name[0],
                            size: 60,
                            colors: const [
                              Color(0xFF8E9BE8),
                              Color(0xFF4A63C4),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.name,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  v.email,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.ink),
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
    );
  }
}
