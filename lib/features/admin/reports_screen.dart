import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../data/mock_data.dart';
import '../../ui/app_dropdown.dart';
import '../../ui/screen_header.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _ranges = ['This Month', 'Last Month', 'This Year'];
  String _range = _ranges.first;

  @override
  Widget build(BuildContext context) {
    const bars = [('Aug', 0.28), ('Sep', 0.45), ('Oct', 0.68), ('Nov', 1.0)];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Event Insights'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  AppDropdown<String>(
                    hint: 'Range',
                    value: _range,
                    items: _ranges,
                    labelOf: (r) => r,
                    onChanged: (r) => setState(() => _range = r ?? _range),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: _Metric('248', 'Registrations')),
                      SizedBox(width: 12),
                      Expanded(child: _Metric('36', 'Volunteers')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '92%',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 14),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Attendance Rate',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final b in bars)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 42,
                                height: 120 * b.$2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8FA2EE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                b.$1,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Top Events',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final t in topEvents)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.$1,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Text(
                            '${t.$2}',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.greySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
