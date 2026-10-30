import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../data/mock_data.dart';
import '../../ui/app_button.dart';
import '../../ui/image_placeholder.dart';
import '../../ui/screen_header.dart';

class AssignVolunteersScreen extends StatefulWidget {
  const AssignVolunteersScreen({super.key, required this.event});

  final MockEvent event;

  @override
  State<AssignVolunteersScreen> createState() => _AssignVolunteersScreenState();
}

class _AssignVolunteersScreenState extends State<AssignVolunteersScreen> {
  final Set<String> _selected = {'Riya Sen', 'Arjun Mehta'};

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Assign Volunteers'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.greySoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        ImagePlaceholder(
                          colors: event.colors,
                          width: 84,
                          height: 84,
                          radius: 14,
                          icon: Icons.image_outlined,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                event.dateFull
                                    .replaceFirst(RegExp(r'^\w{3}, '), ''),
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final v in volunteers.take(4))
                    InkWell(
                      onTap: () => setState(() {
                        if (!_selected.remove(v.name)) _selected.add(v.name);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _selected.contains(v.name),
                              activeColor: AppColors.ink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (_) => setState(() {
                                if (!_selected.remove(v.name)) {
                                  _selected.add(v.name);
                                }
                              }),
                            ),
                            const SizedBox(width: 8),
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
                                  const Text(
                                    'Available',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.muted),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: AppButton(
                label: 'Assign (${_selected.length})',
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Assigning is not wired up yet (UI only).'),
                          ),
                        );
                        Navigator.of(context).maybePop();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
