import 'package:flutter/material.dart';
import 'profile_cover_header.dart';

/// Same visual language as [ProfileSectionCard], for dashboard content areas
/// that already have horizontal padding from [HubContentSheet].
class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.action,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      action: action,
      margin: EdgeInsets.zero,
      child: child,
    );
  }
}
