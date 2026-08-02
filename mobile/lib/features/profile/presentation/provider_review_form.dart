import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/profile_cover_header.dart';
import 'provider_reviews_service.dart';

bool canLeaveProviderReview(AppUser? viewer, {required String providerId, UserRole? providerRole}) {
  if (viewer == null || viewer.id == providerId) return false;
  if (providerRole == UserRole.admin) return false;
  return viewer.role == UserRole.learner || viewer.role == UserRole.client;
}

class ProviderReviewForm extends ConsumerStatefulWidget {
  const ProviderReviewForm({
    super.key,
    required this.providerId,
    required this.providerName,
    this.contextLabel,
  });

  final String providerId;
  final String providerName;
  final String? contextLabel;

  @override
  ConsumerState<ProviderReviewForm> createState() => _ProviderReviewFormState();
}

class _ProviderReviewFormState extends ConsumerState<ProviderReviewForm> {
  final _commentCtrl = TextEditingController();
  var _rating = 5.0;
  var _saving = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final me = ref.read(authProvider).user;
    if (me == null || _commentCtrl.text.trim().isEmpty) return;

    setState(() => _saving = true);
    await ref.read(providerReviewsServiceProvider).addReview(
          providerId: widget.providerId,
          authorName: me.displayName,
          rating: _rating,
          comment: _commentCtrl.text.trim(),
          context: widget.contextLabel ?? s.learn,
          avatarUrl: avatarForUser(me),
        );
    ref.invalidate(providerReviewsListProvider(widget.providerId));
    ref.invalidate(providerStatsProvider(widget.providerId));

    if (!mounted) return;
    setState(() {
      _saving = false;
      _commentCtrl.clear();
      _rating = 5;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.reviewSubmitted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.writeAReview,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            widget.providerName,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if (widget.contextLabel != null && widget.contextLabel!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.contextLabel!,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 14),
          Text(s.yourRating, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: _saving ? null : () => setState(() => _rating = star.toDouble()),
                icon: Icon(
                  _rating >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.accentOrange,
                  size: 30,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            enabled: !_saving,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: s.reviewComment,
              hintText: s.reviewCommentHint,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving || _commentCtrl.text.trim().isEmpty ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(s.submitReview, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
