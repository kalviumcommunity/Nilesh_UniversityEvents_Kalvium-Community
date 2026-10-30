import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../data/mock_data.dart';
import '../../ui/chip_row.dart';
import '../../ui/screen_header.dart';
import '../../ui/search_box.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  static const _filters = ['All', 'Technical', 'Cultural', 'Social'];
  int _filter = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final type = _filters[_filter];
    final q = _query.trim().toLowerCase();
    final visible = clubs
        .where((c) =>
            (type == 'All' || c.type == type) &&
            (q.isEmpty || c.name.toLowerCase().contains(q)))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Clubs'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBox(
                hint: 'Search clubs...',
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
                        'No clubs found',
                        style: TextStyle(color: AppColors.muted, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (context, i) {
                        final c = visible[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: c.colors,
                                  ),
                                ),
                                child:
                                    Icon(c.icon, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${c.members} members',
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.muted),
                            ],
                          ),
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
