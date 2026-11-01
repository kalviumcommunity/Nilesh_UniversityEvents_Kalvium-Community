import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../data/mock_data.dart';
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
  static const _filters = ['All', 'Assigned', 'Pending'];
  int _filter = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final f = _filters[_filter];
    final q = _query.trim().toLowerCase();
    final visible = volunteers
        .where((v) =>
            (f == 'All' || v.status == f) &&
            (q.isEmpty || v.name.toLowerCase().contains(q)))
        .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'Volunteers (36)'),
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
            child: visible.isEmpty
                ? const Center(
                    child: Text(
                      'No volunteers found',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.line),
                    itemBuilder: (context, i) {
                      final v = visible[i];
                      final assigned = v.status == 'Assigned';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            AvatarCircle(
                              initial: v.name[0],
                              size: 60,
                              colors: v.colors,
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
                                    v.status,
                                    style: TextStyle(
                                      color: assigned
                                          ? AppColors.green
                                          : AppColors.orange,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.ink),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
