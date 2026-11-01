import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../ui/app_button.dart';
import '../../ui/app_dropdown.dart';
import '../../ui/app_field.dart';
import '../../ui/screen_header.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const _categories = ['Workshop', 'Talk', 'Hackathon', 'Festival'];
  static const _locations = [
    'Main Auditorium',
    'Seminar Hall',
    'Lab 3',
    'Online'
  ];

  String? _category;
  String? _location;
  DateTime? _when;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _when ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when ?? now),
    );
    if (time == null) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String get _whenLabel {
    final w = _when;
    if (w == null) return 'Date & Time';
    final mm = w.minute.toString().padLeft(2, '0');
    return '${w.day}/${w.month}/${w.year}  ${w.hour}:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Create Event'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB8BBC9), Color(0xFFA3A7B8)],
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              color: Colors.white, size: 34),
                          SizedBox(height: 10),
                          Text(
                            'Add Cover Image',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const AppField(hint: 'Event Title'),
                    const SizedBox(height: 12),
                    AppDropdown<String>(
                      hint: 'Category',
                      value: _category,
                      items: _categories,
                      labelOf: (c) => c,
                      onChanged: (v) => setState(() => _category = v),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _whenLabel,
                                style: TextStyle(
                                  color: _when == null
                                      ? AppColors.muted
                                      : AppColors.ink,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppDropdown<String>(
                      hint: 'Location',
                      value: _location,
                      items: _locations,
                      labelOf: (c) => c,
                      onChanged: (v) => setState(() => _location = v),
                    ),
                    const SizedBox(height: 12),
                    const AppField(
                      hint: 'Description',
                      maxLines: 3,
                      fillColor: AppColors.greySoft,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: AppButton(
                label: 'Create Event',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Saving events is not wired up yet (UI only).'),
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
