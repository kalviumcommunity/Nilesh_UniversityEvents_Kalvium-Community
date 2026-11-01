import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../backend/syncsphere_backend.dart';
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
  late Future<EventReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    _reportFuture = SyncSphereBackend.instance.getEventReport(range: _range);
  }

  @override
  Widget build(BuildContext context) {
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
                    onChanged: (r) => setState(() {
                      _range = r ?? _range;
                      _loadReport();
                    }),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<EventReport>(
                    future: _reportFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Could not load event insights. Check your role access and try again.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final report = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _Metric(
                                  '${report.registrations}',
                                  'Registrations',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _Metric(
                                  '${report.volunteers}',
                                  'Volunteer assignments',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Attendance Rate',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Attendance tracking is not enabled yet.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 16,
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
                          if (report.topEvents.isEmpty)
                            const Text(
                              'No registrations in this range.',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          for (final event in report.topEvents)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.$1,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${event.$2}',
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
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
