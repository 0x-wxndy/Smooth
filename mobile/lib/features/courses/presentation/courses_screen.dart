import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/cards.dart';

class LearnTab extends ConsumerStatefulWidget {
  const LearnTab({super.key});

  @override
  ConsumerState<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends ConsumerState<LearnTab> {
  int _filterIndex = 0;
  static const _filters = ['All', 'Free', 'Premium', 'Saved'];

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SmoothSearchField(readOnly: true, onTap: () => context.push('/search')),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (_, i) => SmoothChipFilter(
                label: _filters[i],
                selected: _filterIndex == i,
                onTap: () => setState(() => _filterIndex = i),
              ),
            ),
          ),
          Expanded(
            child: AsyncValueContent(
              value: coursesAsync,
              builder: (courses) {
                final filtered = switch (_filterIndex) {
                  1 => courses.where((c) => c.isFree).toList(),
                  2 => courses.where((c) => !c.isFree).toList(),
                  _ => courses,
                };
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => CourseCard(
                    course: filtered[i],
                    onTap: () => context.push('/courses/${filtered[i].id}'),
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
