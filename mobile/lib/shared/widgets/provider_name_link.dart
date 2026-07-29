import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Tappable creator name that opens their public profile.
class ProviderNameLink extends StatelessWidget {
  const ProviderNameLink({
    super.key,
    required this.name,
    this.providerId,
    this.style,
    this.iconSize = 14,
  });

  final String name;
  final String? providerId;
  final TextStyle? style;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ??
        const TextStyle(
          color: AppColors.accentPurple,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        );

    if (providerId == null || providerId!.isEmpty) {
      return Text(name, style: style ?? const TextStyle(color: AppColors.textMuted, fontSize: 12));
    }

    return InkWell(
      onTap: () => context.push('/providers/$providerId'),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: iconSize, color: AppColors.accentPurple),
          ],
        ),
      ),
    );
  }
}
