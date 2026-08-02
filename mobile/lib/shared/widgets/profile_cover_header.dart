import 'package:flutter/material.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/user_model.dart';

/// Cover photo + overlapping avatar — used on profile screens.
class ProfileCoverHeader extends StatelessWidget {
  const ProfileCoverHeader({
    super.key,
    required this.coverUrl,
    required this.displayName,
    required this.roleLabel,
    required this.handle,
    this.avatarUrl,
    this.bio,
    this.progress = 0.75,
    this.streak,
    this.trailing,
    this.onShare,
    this.onSettings,
  });

  final String coverUrl;
  final String displayName;
  final String roleLabel;
  final String handle;
  final String? avatarUrl;
  final String? bio;
  final double progress;
  final int? streak;
  final Widget? trailing;
  final VoidCallback? onShare;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 148,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.15),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    if (streak != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, size: 14, color: AppColors.accentOrange),
                            const SizedBox(width: 4),
                            Text(
                              '$streak',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (onShare != null)
                      _GlassIconButton(icon: Icons.ios_share_rounded, onTap: onShare!),
                    if (onSettings != null)
                      _GlassIconButton(icon: Icons.settings_outlined, onTap: onSettings!),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: -36,
              child: _AvatarRing(
                imageUrl: avatarUrl ?? AppAssets.avatar1,
                progress: progress,
              ),
            ),
            if (trailing != null)
              Positioned(right: 16, bottom: -8, child: trailing!),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 44, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.3),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Pill(label: roleLabel, color: AppColors.primary, icon: Icons.badge_outlined),
                  Text(handle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              if (bio != null && bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bio!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.action,
    this.subtitle,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  final Widget? action;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      if (subtitle != null)
                        Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({
    required this.imageUrl,
    required this.progress,
  });

  final String imageUrl;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: progress.clamp(0.05, 1.0),
              strokeWidth: 3,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.accentPurple,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.pastelLavender,
              backgroundImage: profileImageProvider(imageUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

String profileCoverForRole(String roleName) {
  switch (roleName.toLowerCase()) {
    case 'teacher':
    case 'teacher / freelancer':
      return AppAssets.profileCoverCreator;
    case 'client':
      return AppAssets.profileCoverClient;
    case 'admin':
      return AppAssets.heroOffice;
    default:
      return AppAssets.profileCoverLearner;
  }
}

String profileCoverForUser(AppUser user) {
  final options = switch (user.role) {
    UserRole.teacher => [AppAssets.profileCoverCreator, AppAssets.learningDesk, AppAssets.coding],
    UserRole.client => [AppAssets.profileCoverClient, AppAssets.heroWorkspace, AppAssets.marketing],
    UserRole.admin => [AppAssets.heroOffice, AppAssets.coverGeometric],
    UserRole.learner => [AppAssets.profileCoverLearner, AppAssets.coding, AppAssets.design],
  };
  return options[user.id.hashCode.abs() % options.length];
}

String avatarForUser(AppUser user) {
  if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
    return user.avatarUrl!;
  }
  return AppAssets.profileAvatars[user.id.hashCode.abs() % AppAssets.profileAvatars.length];
}

/// Resolves avatar for any user id (enrolled students, etc.).
String avatarForUserId(String userId, {String? avatarUrl}) {
  if (avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('assets/branding/portfolio/')) {
    return avatarUrl;
  }
  return AppAssets.profileAvatars[userId.hashCode.abs() % AppAssets.profileAvatars.length];
}

ImageProvider profileImageProvider(String url) {
  if (url.startsWith('assets/')) {
    return AssetImage(url);
  }
  return NetworkImage(url);
}
