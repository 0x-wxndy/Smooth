import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/cards.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  int _typeIndex = 0;
  static const _types = ['All', 'Courses', 'Services', 'Jobs'];

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search…', border: InputBorder.none),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _types.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_types[i]),
                  selected: _typeIndex == i,
                  onSelected: (_) => setState(() => _typeIndex = i),
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? const Center(child: Text('Type to search courses, services, and jobs'))
                : resultsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (results) {
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (_typeIndex == 0 || _typeIndex == 1) ...[
                            if (results.courses.isNotEmpty)
                              const Text('Courses', style: TextStyle(fontWeight: FontWeight.w700)),
                            ...results.courses.map((c) => CourseCard(course: c)),
                          ],
                          if (_typeIndex == 0 || _typeIndex == 2) ...[
                            if (results.services.isNotEmpty)
                              const Text('Services', style: TextStyle(fontWeight: FontWeight.w700)),
                            ...results.services.map((s) => ServiceCard(service: s)),
                          ],
                          if (_typeIndex == 0 || _typeIndex == 3) ...[
                            if (results.jobs.isNotEmpty)
                              const Text('Jobs', style: TextStyle(fontWeight: FontWeight.w700)),
                            ...results.jobs.map((j) => JobCard(job: j)),
                          ],
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
