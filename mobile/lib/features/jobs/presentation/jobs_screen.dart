import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider(_remoteOnly ? true : null));

    return Scaffold(
      appBar: AppBar(title: const Text('Job Board')),
      body: Column(
        children: [
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
                itemBuilder: (_, i) => JobCard(job: jobs[i], onTap: () {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
