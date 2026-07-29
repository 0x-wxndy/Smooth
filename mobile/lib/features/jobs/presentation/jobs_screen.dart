import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/cards.dart';

class JobsTab extends ConsumerStatefulWidget {
  const JobsTab({super.key});

  @override
  ConsumerState<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<JobsTab> {
  bool _remoteOnly = false;
  final _appliedJobIds = <String>{};

  void _applyToJob(String jobId, String jobTitle) {
    if (_appliedJobIds.contains(jobId)) return;
    setState(() => _appliedJobIds.add(jobId));
    final s = S.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${s.applicationSent} · $jobTitle'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final jobsAsync = ref.watch(jobsProvider(_remoteOnly ? true : null));

    return Scaffold(
      appBar: AppBar(title: Text(s.opportunities)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(s.opportunitiesSub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Wrap(
              spacing: 8,
              children: [
                SmoothChipFilter(
                  label: 'Remote',
                  selected: _remoteOnly,
                  onTap: () => setState(() => _remoteOnly = !_remoteOnly),
                ),
                SmoothChipFilter(label: 'Full-time', selected: false, onTap: () {}),
                SmoothChipFilter(label: 'Internship', selected: false, onTap: () {}),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueContent(
              value: jobsAsync,
              builder: (jobs) => ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: jobs.length,
                itemBuilder: (_, i) {
                  final job = jobs[i];
                  return JobCard(
                    job: job,
                    applied: _appliedJobIds.contains(job.id),
                    onApply: () => _applyToJob(job.id, job.title),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
