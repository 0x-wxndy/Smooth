import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'smooth_components.dart';

class HubNavItem {
  const HubNavItem({required this.label, required this.onTap, this.active = false});
  final String label;
  final VoidCallback onTap;
  final bool active;
}

class HubCta {
  const HubCta({
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
}

/// Shared dark mesh + cover hero used by learner / teacher / client homes.
class HubHeroShell extends StatelessWidget {
  const HubHeroShell({
    super.key,
    required this.brandTitle,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.coverUrl,
    required this.navItems,
    required this.primaryCta,
    required this.secondaryCta,
    this.greeting,
    this.trailing,
    this.coverHeight = 320,
  });

  final String brandTitle;
  final String? greeting;
  final String heroTitle;
  final String heroSubtitle;
  final String coverUrl;
  final List<HubNavItem> navItems;
  final HubCta primaryCta;
  final HubCta secondaryCta;
  final Widget? trailing;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: HubMeshPainter())),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.waves, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        brandTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: Colors.white70),
                      onPressed: () => context.push('/search'),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: navItems
                        .map(
                          (n) => HubNavChip(
                            label: n.label,
                            active: n.active,
                            onTap: n.onTap,
                          ),
                        )
                        .toList(),
                  ),
                ).animate().fadeIn(delay: 80.ms),
                const SizedBox(height: 16),
                NetworkCover(
                  url: coverUrl,
                  height: coverHeight,
                  borderRadius: BorderRadius.circular(28),
                  overlay: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.navy.withValues(alpha: 0.9),
                      AppColors.navy.withValues(alpha: 0.55),
                      AppColors.navy.withValues(alpha: 0.25),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (greeting != null)
                          Text(
                            greeting!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                        const Spacer(),
                        Text(
                          heroTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.12),
                        const SizedBox(height: 10),
                        Text(
                          heroSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _ctaButton(primaryCta, filled: true),
                            _ctaButton(secondaryCta, filled: false),
                          ],
                        ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ctaButton(HubCta cta, {required bool filled}) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    final label = Text(
      cta.label,
      style: TextStyle(
        fontWeight: filled ? FontWeight.w700 : FontWeight.w600,
        fontSize: 13,
      ),
    );

    if (filled) {
      if (cta.icon != null) {
        return FilledButton.icon(
          onPressed: cta.onPressed,
          icon: Icon(cta.icon, size: 18),
          label: label,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: padding,
            shape: shape,
          ),
        );
      }
      return FilledButton(
        onPressed: cta.onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: padding,
          shape: shape,
        ),
        child: label,
      );
    }

    final outlineStyle = OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
      backgroundColor: AppColors.navy.withValues(alpha: 0.35),
      padding: padding,
      shape: shape,
    );
    if (cta.icon != null) {
      return OutlinedButton.icon(
        onPressed: cta.onPressed,
        icon: Icon(cta.icon, size: 18),
        label: label,
        style: outlineStyle,
      );
    }
    return OutlinedButton(
      onPressed: cta.onPressed,
      style: outlineStyle,
      child: label,
    );
  }
}

class HubNavChip extends StatelessWidget {
  const HubNavChip({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class HubMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = AppColors.navy;
    canvas.drawRect(Offset.zero & size, fill);

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const step = 48.0;
    for (var x = -step; x < size.width + step; x += step) {
      for (var y = -step; y < size.height + step; y += step) {
        final path = Path()
          ..moveTo(x, y + step * 0.5)
          ..lineTo(x + step * 0.5, y)
          ..lineTo(x + step, y + step * 0.5)
          ..lineTo(x + step * 0.5, y + step)
          ..close();
        canvas.drawPath(path, line);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Light sheet that sits under the navy hero.
class HubContentSheet extends StatelessWidget {
  const HubContentSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: child,
    );
  }
}
