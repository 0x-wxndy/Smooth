import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/app_providers.dart';

class ShellNavItem {
  const ShellNavItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

List<ShellNavItem> navItemsForRole(UserRole role) {
  switch (role) {
    case UserRole.teacher:
      return const [
        ShellNavItem(path: '/home', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard'),
        ShellNavItem(path: '/teacher/courses', icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Courses'),
        ShellNavItem(path: '/teacher/services', icon: Icons.design_services_outlined, selectedIcon: Icons.design_services, label: 'Services'),
        ShellNavItem(path: '/market', icon: Icons.storefront_outlined, selectedIcon: Icons.storefront, label: 'Market'),
        ShellNavItem(path: '/profile', icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
      ];
    case UserRole.client:
      return const [
        ShellNavItem(path: '/home', icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
        ShellNavItem(path: '/market', icon: Icons.storefront_outlined, selectedIcon: Icons.storefront, label: 'Market'),
        ShellNavItem(path: '/jobs', icon: Icons.work_outline, selectedIcon: Icons.work, label: 'Jobs'),
        ShellNavItem(path: '/learn', icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Learn'),
        ShellNavItem(path: '/profile', icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
      ];
    case UserRole.learner:
    case UserRole.admin:
      return const [
        ShellNavItem(path: '/home', icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
        ShellNavItem(path: '/learn', icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Learn'),
        ShellNavItem(path: '/market', icon: Icons.storefront_outlined, selectedIcon: Icons.storefront, label: 'Market'),
        ShellNavItem(path: '/jobs', icon: Icons.work_outline, selectedIcon: Icons.work, label: 'Jobs'),
        ShellNavItem(path: '/profile', icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
      ];
  }
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location, List<ShellNavItem> items) {
    for (var i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role ?? UserRole.learner;
    final items = navItemsForRole(role);
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexForLocation(location, items);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index.clamp(0, items.length - 1),
        onDestinationSelected: (i) => context.go(items[i].path),
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
