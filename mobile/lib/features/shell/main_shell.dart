import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/app_providers.dart';
import '../../features/onboarding/first_visit_onboarding.dart';
import '../../features/onboarding/onboarding_service.dart';

class ShellNavItem {
  const ShellNavItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.labelBuilder,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(S s) labelBuilder;
}

List<ShellNavItem> navItemsForRole(UserRole role) {
  switch (role) {
    case UserRole.teacher:
      return [
        ShellNavItem(
          path: '/home',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          labelBuilder: (s) => s.dashboard,
        ),
        ShellNavItem(
          path: '/teacher/courses',
          icon: Icons.menu_book_outlined,
          selectedIcon: Icons.menu_book,
          labelBuilder: (s) => s.courses,
        ),
        ShellNavItem(
          path: '/market',
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
          labelBuilder: (s) => s.market,
        ),
        ShellNavItem(
          path: '/hub',
          icon: Icons.apartment_outlined,
          selectedIcon: Icons.apartment,
          labelBuilder: (s) => s.hub,
        ),
        ShellNavItem(
          path: '/jobs',
          icon: Icons.work_outline,
          selectedIcon: Icons.work,
          labelBuilder: (s) => s.opportunities,
        ),
        ShellNavItem(
          path: '/messages',
          icon: Icons.mail_outline,
          selectedIcon: Icons.mail,
          labelBuilder: (s) => s.messages,
        ),
        ShellNavItem(
          path: '/profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          labelBuilder: (s) => s.profile,
        ),
      ];
    case UserRole.client:
      return [
        ShellNavItem(
          path: '/home',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          labelBuilder: (s) => s.home,
        ),
        ShellNavItem(
          path: '/market',
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
          labelBuilder: (s) => s.market,
        ),
        ShellNavItem(
          path: '/messages',
          icon: Icons.mail_outline,
          selectedIcon: Icons.mail,
          labelBuilder: (s) => s.messages,
        ),
        ShellNavItem(
          path: '/profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          labelBuilder: (s) => s.profile,
        ),
      ];
    case UserRole.admin:
      return [
        ShellNavItem(
          path: '/home',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          labelBuilder: (s) => s.dashboard,
        ),
        ShellNavItem(
          path: '/admin/users',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          labelBuilder: (s) => s.users,
        ),
        ShellNavItem(
          path: '/admin/reports',
          icon: Icons.flag_outlined,
          selectedIcon: Icons.flag,
          labelBuilder: (s) => s.reports,
        ),
        ShellNavItem(
          path: '/messages',
          icon: Icons.mail_outline,
          selectedIcon: Icons.mail,
          labelBuilder: (s) => s.messages,
        ),
        ShellNavItem(
          path: '/profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          labelBuilder: (s) => s.profile,
        ),
      ];
    case UserRole.learner:
      return [
        ShellNavItem(
          path: '/home',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          labelBuilder: (s) => s.home,
        ),
        ShellNavItem(
          path: '/learn',
          icon: Icons.menu_book_outlined,
          selectedIcon: Icons.menu_book,
          labelBuilder: (s) => s.learn,
        ),
        ShellNavItem(
          path: '/market',
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
          labelBuilder: (s) => s.market,
        ),
        ShellNavItem(
          path: '/messages',
          icon: Icons.mail_outline,
          selectedIcon: Icons.mail,
          labelBuilder: (s) => s.messages,
        ),
        ShellNavItem(
          path: '/profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          labelBuilder: (s) => s.profile,
        ),
      ];
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  String? _onboardingCheckedForUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowOnboarding());
  }

  Future<void> _maybeShowOnboarding() async {
    final user = ref.read(authProvider).user;
    if (user == null || !mounted) return;
    if (_onboardingCheckedForUser == user.id) return;
    _onboardingCheckedForUser = user.id;

    final service = ref.read(onboardingServiceProvider);
    if (await service.hasSeenOnboarding(user.id)) return;
    if (!mounted) return;

    await showFirstVisitOnboarding(
      context: context,
      ref: ref,
      role: user.role,
      userId: user.id,
    );
  }

  int _indexForLocation(String location, List<ShellNavItem> items) {
    var best = 0;
    var bestLen = -1;
    for (var i = 0; i < items.length; i++) {
      final path = items[i].path;
      if (location == path || location.startsWith('$path/')) {
        if (path.length > bestLen) {
          bestLen = path.length;
          best = i;
        }
      } else if (location.startsWith(path) && path.length > bestLen) {
        // Exact prefix for leaf routes like `/home`
        bestLen = path.length;
        best = i;
      }
    }
    return bestLen >= 0 ? best : 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? UserRole.learner;
    final items = navItemsForRole(role);
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexForLocation(location, items);

    final compactNav = items.length > 4;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontSize: compactNav ? 10 : 11,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: index.clamp(0, items.length - 1),
          height: compactNav ? 68 : 80,
          labelBehavior: compactNav
              ? NavigationDestinationLabelBehavior.onlyShowSelected
              : NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => context.go(items[i].path),
          destinations: items
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.labelBuilder(s),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
