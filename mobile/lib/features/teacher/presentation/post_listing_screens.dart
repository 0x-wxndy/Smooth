import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/smooth_button.dart';

class PostCourseScreen extends ConsumerStatefulWidget {
  const PostCourseScreen({super.key});

  @override
  ConsumerState<PostCourseScreen> createState() => _PostCourseScreenState();
}

class _PostCourseScreenState extends ConsumerState<PostCourseScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  CourseCategory _category = CourseCategory.softwareDev;
  Difficulty _difficulty = Difficulty.beginner;
  bool _isFree = true;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    if (_title.text.trim().isEmpty || _desc.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.fillRequired)));
      return;
    }
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    final dinars = int.tryParse(_price.text.trim()) ?? 0;
    await ref.read(databaseProvider).createCourse(
          teacherId: userId,
          title: _title.text,
          description: _desc.text,
          category: _category,
          difficulty: _difficulty,
          isFree: _isFree,
          priceCents: _isFree ? null : Money.dzd(dinars),
        );
    ref.invalidate(myCoursesProvider);
    ref.invalidate(coursesProvider);
    ref.invalidate(gamificationProvider);
    setState(() => _saving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.coursePostedReward(AppConfig.postCourseCoins)),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.postCourse)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pastelMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              s.creatorEarnHint,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: s.courseTitle, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 4,
            decoration: InputDecoration(labelText: s.description, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CourseCategory>(
            value: _category,
            decoration: InputDecoration(labelText: s.categories, border: const OutlineInputBorder()),
            items: CourseCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Difficulty>(
            value: _difficulty,
            decoration: InputDecoration(labelText: s.difficulty, border: const OutlineInputBorder()),
            items: [
              DropdownMenuItem(value: Difficulty.beginner, child: Text(s.beginner)),
              DropdownMenuItem(value: Difficulty.intermediate, child: Text(s.intermediate)),
              DropdownMenuItem(value: Difficulty.advanced, child: Text(s.advanced)),
            ],
            onChanged: (v) => setState(() => _difficulty = v ?? _difficulty),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.free),
            value: _isFree,
            onChanged: (v) => setState(() => _isFree = v),
          ),
          if (!_isFree)
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${s.price} (DZD)',
                border: const OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 24),
          SmoothButton(
            label: s.publishCourse,
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class PostServiceScreen extends ConsumerStatefulWidget {
  const PostServiceScreen({super.key});

  @override
  ConsumerState<PostServiceScreen> createState() => _PostServiceScreenState();
}

class _PostServiceScreenState extends ConsumerState<PostServiceScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController(text: '5000');
  final _days = TextEditingController(text: '7');
  String _category = 'Design';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    if (_title.text.trim().isEmpty || _desc.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.fillRequired)));
      return;
    }
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    final dinars = int.tryParse(_price.text.trim()) ?? 5000;
    final days = int.tryParse(_days.text.trim()) ?? 7;
    await ref.read(databaseProvider).createService(
          providerId: userId,
          title: _title.text,
          description: _desc.text,
          category: _category,
          priceCents: Money.dzd(dinars),
          deliveryDays: days,
        );
    ref.invalidate(myServicesProvider);
    ref.invalidate(servicesProvider);
    ref.invalidate(gamificationProvider);
    setState(() => _saving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.servicePostedReward(AppConfig.postServiceCoins)),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.postService)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pastelPeach,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(s.creatorEarnHint, style: const TextStyle(fontSize: 13, height: 1.35)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: s.serviceTitle, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 4,
            decoration: InputDecoration(labelText: s.description, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: InputDecoration(labelText: s.categories, border: const OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Design', child: Text('Design')),
              DropdownMenuItem(value: 'Development', child: Text('Development')),
              DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
              DropdownMenuItem(value: 'Writing', child: Text('Writing')),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '${s.price} (DZD)', border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _days,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.deliveryDays, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SmoothButton(
            label: s.publishService,
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
