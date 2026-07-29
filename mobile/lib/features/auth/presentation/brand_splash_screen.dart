import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/smooth_components.dart';

/// First screen shown while the app boots — logo + brand slogan.
class BrandSplashScreen extends StatelessWidget {
  const BrandSplashScreen({super.key, this.locale = const Locale('fr')});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final s = S(locale);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628),
              AppColors.navy,
              Color(0xFF152238),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 3),
                const SmoothBrandMark(size: 120, borderRadius: 24),
                const SizedBox(height: 36),
                Text(
                  s.splashTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: locale.languageCode == 'ar' ? 0 : 1.8,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  s.splashSlogan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: locale.languageCode == 'ar' ? 20 : 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: locale.languageCode == 'ar' ? 0 : 0.6,
                    height: 1.25,
                  ),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
