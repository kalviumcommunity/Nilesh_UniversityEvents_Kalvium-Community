import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../backend/syncsphere_backend.dart';
import '../../data/app_models.dart';
import '../../ui/app_button.dart';
import '../../ui/image_placeholder.dart';
import '../../ui/screen_header.dart';

class AssignVolunteersScreen extends StatefulWidget {
  const AssignVolunteersScreen({super.key, required this.event});

  final CampusEvent event;

  @override
  State<AssignVolunteersScreen> createState() => _AssignVolunteersScreenState();
}

class _AssignVolunteersScreenState extends State<AssignVolunteersScreen> {
  final Set<String> _selected = {};
  bool _isSaving = false;

  Future<void> _assign() async {
    setState(() => _isSaving = true);
    try {
      await SyncSphereBackend.instance.assignVolunteers(
        eventId: widget.event.id,
        volunteerUids: _selected.toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Volunteers assigned.')),
      );
    } on BackendException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

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
                  StreamBuilder<List<AppUser>>(
                    stream: SyncSphereBackend.instance.watchStudentDirectory(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Could not load student directory.'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No student accounts are available yet.'),
                        );
                      }
                      return Column(
                        children: [
                          for (final user in snapshot.data!)
                            InkWell(
                              onTap: () => setState(() {
                                if (!_selected.remove(user.id)) {
                                  _selected.add(user.id);
                                }
                              }),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _selected.contains(user.id),
                                      activeColor: AppColors.ink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      onChanged: (_) => setState(() {
                                        if (!_selected.remove(user.id)) {
                                          _selected.add(user.id);
                                        }
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            style: const TextStyle(
                                              color: AppColors.ink,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            user.email,
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.muted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: AppButton(
                label:
                    _isSaving ? 'Assigning...' : 'Assign (${_selected.length})',
                onPressed: _selected.isEmpty || _isSaving ? null : _assign,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
