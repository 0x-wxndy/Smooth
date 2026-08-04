import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/models/hub_admin_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/hub_hero.dart';
import '../../../shared/widgets/back_to_menu_bar.dart';
import '../../../shared/widgets/smooth_components.dart';

Future<void> _logAdminAction(
  WidgetRef ref, {
  required String action,
  String? targetType,
  String? targetId,
  String? details,
}) async {
  final admin = ref.read(authProvider).user;
  await ref.read(databaseProvider).insertAdminActivityLog(
        actorId: admin?.id,
        actorName: admin?.displayName,
        action: action,
        targetType: targetType,
        targetId: targetId,
        details: details,
      );
  ref.invalidate(adminActivityLogsProvider);
}

/// Sub-pages opened from the dashboard — always show a back affordance.
class AdminSubpageScaffold extends StatelessWidget {
  const AdminSubpageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(title),
        actions: actions,
      ),
      body: body,
    );
  }
}

class AdminDashboardTab extends ConsumerWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: BackToMenuBar()),
          SliverToBoxAdapter(child: _AdminHero(s: s)),
          SliverToBoxAdapter(
            child: HubContentSheet(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: AsyncValueContent(
                  value: statsAsync,
                  builder: (stats) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(s.adminAnalytics, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _Stat(s.teachers, '${stats.teachers}', Icons.school, AppColors.accentPurple, () => context.go('/admin/users'))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.bookings, '${stats.serviceBookings}', Icons.event_available, AppColors.accentGreen, () => context.push('/admin/market'))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.reports, '${stats.openReports}', Icons.flag, AppColors.error, () => context.go('/admin/reports'))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _Stat(s.learners, '${stats.learners}', Icons.menu_book, AppColors.accentBlue, () => context.go('/admin/users'))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.clients, '${stats.clients}', Icons.business_center, AppColors.accentOrange, () => context.go('/admin/users'))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.messages, '${stats.newMessages}', Icons.mail, AppColors.primary, () => context.go('/messages'))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _Stat(s.rooms, '${stats.roomBookings}', Icons.meeting_room, AppColors.navySoft, () => context.push('/admin/rooms'))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.printOrders, '${stats.printOrders}', Icons.print, AppColors.accentPink, () => context.push('/admin/print'))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.courses, '${stats.courses}', Icons.library_books, AppColors.accentPurple, () => context.push('/admin/market'))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              s.escrowDeals,
                              '${stats.escrowActive}',
                              Icons.handshake_outlined,
                              AppColors.accentGreen,
                              () => context.push('/admin/logs'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Stat(
                              s.escrowCompletedDeals,
                              '${stats.escrowCompleted}',
                              Icons.verified_outlined,
                              AppColors.primary,
                              () => context.push('/admin/logs'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Stat(
                              s.platformRevenue,
                              stats.platformFeesLabel,
                              Icons.account_balance_outlined,
                              AppColors.accentOrange,
                              () => context.push('/admin/logs'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(s.adminQuickActions, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 10),
                      _AdminTile(Icons.people, s.manageUsers, s.manageUsersSub, AppColors.accentBlue, () => context.go('/admin/users')),
                      _AdminTile(Icons.flag_outlined, s.manageReports, s.manageReportsSub, AppColors.error, () => context.go('/admin/reports')),
                      _AdminTile(Icons.storefront, s.manageMarketplace, s.manageMarketplaceSub, AppColors.accentPurple, () => context.push('/admin/market')),
                      _AdminTile(Icons.meeting_room_outlined, s.manageRooms, s.manageRoomsSub, AppColors.primary, () => context.push('/admin/rooms')),
                      _AdminTile(Icons.print_outlined, s.managePrint, s.managePrintSub, AppColors.accentOrange, () => context.push('/admin/print')),
                      _AdminTile(Icons.receipt_long_outlined, s.manageLogs, s.manageLogsSub, AppColors.navy, () => context.push('/admin/logs')),
                      _AdminTile(Icons.mail_outline, s.manageMessages, s.manageMessagesSub, AppColors.accentGreen, () => context.go('/messages')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  const _AdminHero({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    return HubHeroShell(
        brandTitle: s.adminPanel,
        greeting: s.adminWelcome,
        heroTitle: s.adminHeroTitle,
        heroSubtitle: s.adminHeroSubtitle,
        coverUrl: AppAssets.heroOffice,
        coverHeight: 300,
        primaryCta: HubCta(
          label: s.manageUsers,
          icon: Icons.people,
          onPressed: () => context.go('/admin/users'),
        ),
        secondaryCta: HubCta(
          label: s.manageReports,
          icon: Icons.flag,
          onPressed: () => context.go('/admin/reports'),
        ),
      );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon, this.color, this.onTap);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SoftMetricCard(
          background: color.withValues(alpha: 0.12),
          icon: icon,
          iconColor: color,
          label: label,
          value: value,
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile(this.icon, this.title, this.sub, this.color, this.onTap);
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ── Users ───────────────────────────────────────────────────────────

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<AppUser> _filterUsers(List<AppUser> users, int tabIndex) {
    final nonAdmin = users.where((u) => u.role != UserRole.admin).toList();
    return switch (tabIndex) {
      1 => nonAdmin.where((u) => u.role == UserRole.learner).toList(),
      2 => nonAdmin.where((u) => u.role == UserRole.teacher).toList(),
      3 => nonAdmin.where((u) => u.role == UserRole.client).toList(),
      _ => nonAdmin,
    };
  }

  Future<void> _editUser(BuildContext context, AppUser user) async {
    final s = S.of(context);
    final nameCtrl = TextEditingController(text: user.displayName);
    final bioCtrl = TextEditingController(text: user.bio ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.editUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: s.displayName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              maxLines: 2,
              decoration: InputDecoration(labelText: s.bio),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.save)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(databaseProvider).updateUserProfile(
          userId: user.id,
          displayName: nameCtrl.text.trim(),
          bio: bioCtrl.text.trim(),
        );
    await _logAdminAction(ref, action: 'user.updated', targetType: 'user', targetId: user.id, details: nameCtrl.text.trim());
    ref.invalidate(allUsersProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.userUpdated)));
  }

  Future<void> _confirmDelete(BuildContext context, AppUser user) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteUser),
        content: Text(s.deleteUserConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(databaseProvider).deleteUser(user.id);
    await _logAdminAction(ref, action: 'user.deleted', targetType: 'user', targetId: user.id, details: user.email);
    ref.invalidate(allUsersProvider);
    ref.invalidate(adminStatsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.userDeleted)));
  }

  Future<void> _toggleBlock(BuildContext context, AppUser user, bool block) async {
    final s = S.of(context);
    await ref.read(databaseProvider).setUserBlocked(user.id, block);
    await _logAdminAction(
      ref,
      action: block ? 'user.blocked' : 'user.unblocked',
      targetType: 'user',
      targetId: user.id,
      details: user.email,
    );
    ref.invalidate(allUsersProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(block ? s.userBlocked : s.userUnlocked)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(s.manageUsers),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            Tab(text: s.allUsers),
            Tab(text: s.learners),
            Tab(text: s.teachers),
            Tab(text: s.clients),
          ],
        ),
      ),
      body: AsyncValueContent(
        value: usersAsync,
        builder: (users) => AnimatedBuilder(
          animation: _tabs,
          builder: (context, _) {
            final filtered = _filterUsers(users, _tabs.index);
            if (filtered.isEmpty) {
              return Center(child: Text(s.noUsersInCategory));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final u = filtered[i];
            return InkWell(
              onTap: () => context.push('/providers/${u.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: u.isBlocked ? AppColors.surfaceVariant : AppColors.pastelMint,
                      child: Text(u.displayName.characters.first.toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            '${u.email}\n${roleDisplayName(u.role)}${u.isBlocked ? ' · ${s.blockUser}' : ''}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                        onSelected: (action) async {
                          switch (action) {
                            case 'edit':
                              await _editUser(context, u);
                            case 'block':
                              await _toggleBlock(context, u, true);
                            case 'unlock':
                              await _toggleBlock(context, u, false);
                            case 'delete':
                              await _confirmDelete(context, u);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'edit', child: Text(s.editUser)),
                          if (!u.isBlocked)
                            PopupMenuItem(value: 'block', child: Text(s.blockUser))
                          else
                            PopupMenuItem(value: 'unlock', child: Text(s.unlockUser)),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(s.deleteUser, style: const TextStyle(color: AppColors.error)),
                          ),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                  ],
                ),
              ),
            ),
            );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Reports ─────────────────────────────────────────────────────────

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(s.manageReports),
        automaticallyImplyLeading: false,
      ),
      body: AsyncValueContent(
        value: reportsAsync,
        builder: (reports) {
          if (reports.isEmpty) {
            return Center(child: Text(s.noReports));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (_, i) {
              final r = reports[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag, color: r.status == 'open' ? AppColors.error : AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r.reason, style: const TextStyle(fontWeight: FontWeight.w800))),
                          Text(r.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${s.reported}: ${r.reportedName ?? r.reportedUserId}'),
                      Text('${s.reporter}: ${r.reporterName ?? r.reporterId}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      if (r.details != null) ...[
                        const SizedBox(height: 6),
                        Text(r.details!, style: const TextStyle(fontSize: 13, height: 1.35)),
                      ],
                      if (r.status == 'open') ...[
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => context.push('/providers/${r.reportedUserId}'),
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: Text(s.viewProfile),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await ref.read(databaseProvider).updateReportStatus(r.id, 'resolved');
                                await _logAdminAction(ref, action: 'report.resolved', targetType: 'report', targetId: r.id);
                                ref.invalidate(reportsProvider);
                                ref.invalidate(adminStatsProvider);
                              },
                              child: Text(s.resolve),
                            ),
                            TextButton(
                              onPressed: () async {
                                await ref.read(databaseProvider).updateReportStatus(r.id, 'dismissed');
                                await _logAdminAction(ref, action: 'report.dismissed', targetType: 'report', targetId: r.id);
                                ref.invalidate(reportsProvider);
                                ref.invalidate(adminStatsProvider);
                              },
                              child: Text(s.dismiss),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Marketplace management ──────────────────────────────────────────

class AdminMarketScreen extends ConsumerWidget {
  const AdminMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final coursesAsync = ref.watch(coursesProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final bookingsAsync = ref.watch(serviceBookingsProvider);

    return AdminSubpageScaffold(
      title: s.manageMarketplace,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminSectionHeader(title: s.bookings, icon: Icons.event_available),
          const SizedBox(height: 8),
          AsyncValueContent(
            value: bookingsAsync,
            builder: (bookings) {
              if (bookings.isEmpty) {
                return _AdminEmptyHint(text: s.noBookings);
              }
              return Column(
                children: bookings.map((b) => _AdminRecordCard(
                      title: b.serviceTitle ?? b.serviceId,
                      subtitle: '${b.clientName} → ${b.providerName}',
                      trailing: Money.format(b.totalCents),
                      icon: Icons.handshake_outlined,
                      iconColor: AppColors.accentGreen,
                    )).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          _AdminSectionHeader(title: s.courses, icon: Icons.menu_book_outlined),
          AsyncValueContent(
            value: coursesAsync,
            builder: (courses) => Column(
              children: courses
                  .map(
                    (c) => _AdminRecordCard(
                      title: c.title,
                      subtitle: c.teacherName ?? '',
                      icon: Icons.school_outlined,
                      iconColor: AppColors.accentPurple,
                      onTap: () => context.push('/courses/${c.id}'),
                      trailingAction: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () async {
                          await ref.read(databaseProvider).deleteCourse(c.id);
                          await _logAdminAction(ref, action: 'course.deleted', targetType: 'course', targetId: c.id, details: c.title);
                          ref.invalidate(coursesProvider);
                          ref.invalidate(adminStatsProvider);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _AdminSectionHeader(title: s.services, icon: Icons.design_services_outlined),
          AsyncValueContent(
            value: servicesAsync,
            builder: (services) => Column(
              children: services
                  .map(
                    (svc) => _AdminRecordCard(
                      title: svc.title,
                      subtitle: svc.providerName ?? '',
                      trailing: svc.priceLabel,
                      icon: Icons.work_outline,
                      iconColor: AppColors.primary,
                      onTap: () => context.push('/services/${svc.id}'),
                      trailingAction: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () async {
                          await ref.read(databaseProvider).deleteService(svc.id);
                          await _logAdminAction(ref, action: 'service.deleted', targetType: 'service', targetId: svc.id, details: svc.title);
                          ref.invalidate(servicesProvider);
                          ref.invalidate(adminStatsProvider);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rooms admin ─────────────────────────────────────────────────────

class AdminRoomsScreen extends ConsumerWidget {
  const AdminRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final roomsAsync = ref.watch(roomsProvider);
    final bookingsAsync = ref.watch(roomBookingsProvider);

    return AdminSubpageScaffold(
      title: s.manageRooms,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminSectionHeader(title: s.rooms, icon: Icons.meeting_room_outlined),
          AsyncValueContent(
            value: roomsAsync,
            builder: (rooms) => Column(
              children: rooms
                  .map(
                    (room) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: SwitchListTile(
                        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          '${room.priceHourLabel} · ${room.priceDayLabel}\n${s.capacity}: ${room.capacity}',
                        ),
                        isThreeLine: true,
                        value: room.available,
                        onChanged: (v) async {
                          await ref.read(databaseProvider).setRoomAvailability(room.id, v);
                          await _logAdminAction(
                            ref,
                            action: v ? 'room.enabled' : 'room.disabled',
                            targetType: 'room',
                            targetId: room.id,
                            details: room.name,
                          );
                          ref.invalidate(roomsProvider);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _AdminSectionHeader(title: s.roomBookings, icon: Icons.calendar_month_outlined),
          const SizedBox(height: 8),
          AsyncValueContent(
            value: bookingsAsync,
            builder: (bookings) {
              if (bookings.isEmpty) return _AdminEmptyHint(text: s.noBookings);
              return Column(
                children: bookings
                    .map(
                      (b) => _AdminRecordCard(
                        title: b.roomName ?? b.roomId,
                        subtitle: '${b.userName} · ${b.billing}',
                        trailing: Money.format(b.totalCents),
                        icon: Icons.event_seat_outlined,
                        iconColor: AppColors.navySoft,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Print admin ─────────────────────────────────────────────────────

class AdminPrintScreen extends ConsumerWidget {
  const AdminPrintScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final ordersAsync = ref.watch(printOrdersProvider);
    final servicesAsync = ref.watch(printServicesProvider);

    return AdminSubpageScaffold(
      title: s.managePrint,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminSectionHeader(title: s.printCatalog, icon: Icons.inventory_2_outlined),
          AsyncValueContent(
            value: servicesAsync,
            builder: (items) => Column(
              children: items
                  .map(
                    (p) => _AdminRecordCard(
                      title: p.title,
                      subtitle: p.description,
                      trailing: '${p.priceLabel} / ${p.unit}',
                      icon: Icons.print_outlined,
                      iconColor: AppColors.accentOrange,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _AdminSectionHeader(title: s.printOrders, icon: Icons.receipt_outlined),
          AsyncValueContent(
            value: ordersAsync,
            builder: (orders) {
              if (orders.isEmpty) return _AdminEmptyHint(text: s.noOrders);
              return Column(
                children: orders.map((o) {
                  return _AdminRecordCard(
                    title: o.serviceTitle ?? o.serviceId,
                    subtitle: '${o.userName} · x${o.quantity} · ${o.status}',
                    trailing: Money.format(o.totalCents),
                    icon: Icons.local_shipping_outlined,
                    iconColor: o.status == 'pending' ? AppColors.accentOrange : AppColors.success,
                    trailingAction: o.status == 'pending'
                        ? FilledButton(
                            onPressed: () async {
                              await ref.read(databaseProvider).updatePrintOrderStatus(o.id, 'done');
                              await _logAdminAction(ref, action: 'print_order.done', targetType: 'print_order', targetId: o.id);
                              ref.invalidate(printOrdersProvider);
                              ref.invalidate(adminStatsProvider);
                            },
                            child: Text(s.markDone),
                          )
                        : null,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Logs & payments ─────────────────────────────────────────────────

class AdminLogsScreen extends ConsumerStatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  ConsumerState<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends ConsumerState<AdminLogsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final paymentsAsync = ref.watch(paymentLogsProvider);
    final activityAsync = ref.watch(adminActivityLogsProvider);

    return AdminSubpageScaffold(
      title: s.manageLogs,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: s.paymentLogs),
              Tab(text: s.activityLogs),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                AsyncValueContent(
                  value: paymentsAsync,
                  builder: (logs) {
                    if (logs.isEmpty) return Center(child: Text(s.noPaymentLogs));
                    final escrowFunded = logs.where((l) => l.purpose == 'escrow' && l.isSuccess).length;
                    final escrowFees = logs
                        .where((l) => l.purpose == 'escrowRelease' && l.isSuccess)
                        .fold<int>(0, (sum, l) => sum + l.amountCents);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (escrowFunded > 0 || escrowFees > 0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.pastelMint,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.escrowTracking, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.escrowTrackingSummary(escrowFunded, Money.format(escrowFees)),
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final log = logs[i];
                              return _AdminRecordCard(
                                title: log.title,
                                subtitle:
                                    '${log.userName ?? s.anonymousUser} · ${_paymentPurposeLabel(s, log.purpose)} · ${log.gateway}',
                                trailing: log.amountLabel,
                                icon: log.isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                                iconColor: log.isSuccess ? AppColors.success : AppColors.error,
                                footer: log.reference ?? _formatLogTime(context, log.createdAt),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                AsyncValueContent(
                  value: activityAsync,
                  builder: (logs) {
                    if (logs.isEmpty) return Center(child: Text(s.noActivityLogs));
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final log = logs[i];
                        return _AdminRecordCard(
                          title: log.action,
                          subtitle: log.details ?? log.targetId ?? '',
                          trailing: log.actorName ?? s.system,
                          icon: Icons.history,
                          iconColor: AppColors.navy,
                          footer: _formatLogTime(context, log.createdAt),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSectionHeader extends StatelessWidget {
  const _AdminSectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}

class _AdminEmptyHint extends StatelessWidget {
  const _AdminEmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}

class _AdminRecordCard extends StatelessWidget {
  const _AdminRecordCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
    this.footer,
    this.onTap,
    this.trailingAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? trailing;
  final String? footer;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35)),
                    if (footer != null) ...[
                      const SizedBox(height: 6),
                      Text(footer!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                Text(trailing!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              if (trailingAction != null) trailingAction!,
            ],
          ),
        ),
      ),
    );
  }
}

String _formatLogTime(BuildContext context, String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('d MMM yyyy · HH:mm').format(dt);
  } catch (_) {
    return iso;
  }
}

String _paymentPurposeLabel(S s, String purpose) => switch (purpose) {
      'escrow' => s.paymentPurposeEscrow,
      'escrowRelease' => s.paymentPurposeEscrowRelease,
      _ => purpose,
    };

// ── Messages ────────────────────────────────────────────────────────

class AdminMessagesScreen extends ConsumerStatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  ConsumerState<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends ConsumerState<AdminMessagesScreen> {
  ContactMessage? _selected;

  Future<void> _openThread(ContactMessage message) async {
    if (message.status == 'new') {
      await ref.read(databaseProvider).markContactRead(message.id);
      ref.invalidate(contactMessagesProvider);
      ref.invalidate(adminStatsProvider);
    }
    setState(() => _selected = message);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final msgsAsync = ref.watch(contactMessagesProvider);

    if (_selected != null) {
      return _ContactThreadView(
        message: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.manageMessages),
            Text(
              s.manageMessagesSub,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: AsyncValueContent(
        value: msgsAsync,
        builder: (msgs) {
          if (msgs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forum_outlined, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(s.noMessages, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: msgs.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
            itemBuilder: (_, i) => _ContactInboxTile(
              message: msgs[i],
              onTap: () => _openThread(msgs[i]),
              timeLabel: _formatMessageTime(context, msgs[i].createdAt),
            ),
          );
        },
      ),
    );
  }
}

class _ContactInboxTile extends StatelessWidget {
  const _ContactInboxTile({
    required this.message,
    required this.onTap,
    required this.timeLabel,
  });

  final ContactMessage message;
  final VoidCallback onTap;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final unread = message.status == 'new';
    return Material(
      color: unread ? AppColors.pastelSky.withValues(alpha: 0.45) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: unread ? AppColors.primary.withValues(alpha: 0.15) : AppColors.pastelMint,
                child: Text(
                  message.name.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: unread ? AppColors.primary : AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.name,
                            style: TextStyle(
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                            color: unread ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactThreadView extends StatelessWidget {
  const _ContactThreadView({required this.message, required this.onBack});

  final ContactMessage message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.pastelMint,
              child: Text(message.name.characters.first.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    message.email,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: const Color(0xFFF0F2F5),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  _ThreadMetaChip(label: _formatThreadDate(context, message.createdAt)),
                  _ThreadMetaChip(label: message.subject, icon: Icons.topic_outlined),
                  _ContactMessageBubble(
                    senderName: message.name,
                    body: message.body,
                    time: _formatMessageTime(context, message.createdAt),
                    incoming: true,
                  ),
                ],
              ),
            ),
          ),
          Material(
            elevation: 6,
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${s.replyViaEmail} · ${AppConfig.hubEmail}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactMessageBubble extends StatelessWidget {
  const _ContactMessageBubble({
    required this.senderName,
    required this.body,
    required this.time,
    required this.incoming,
  });

  final String senderName;
  final String body;
  final String time;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = incoming ? Colors.white : AppColors.primary;
    final textColor = incoming ? AppColors.textPrimary : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: incoming ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (incoming) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.pastelMint,
              child: Text(senderName.characters.first.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(incoming ? 4 : 16),
                  bottomRight: Radius.circular(incoming ? 16 : 4),
                ),
                boxShadow: incoming
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (incoming)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                  Text(body, style: TextStyle(color: textColor, height: 1.4)),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 11, color: incoming ? AppColors.textSecondary : Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadMetaChip extends StatelessWidget {
  const _ThreadMetaChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMessageTime(BuildContext context, String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat.Hm().format(dt);
    }
    return DateFormat('d MMM', locale).format(dt);
  } catch (_) {
    return '';
  }
}

String _formatThreadDate(BuildContext context, String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return S.of(context).today;
    }
    return DateFormat('EEEE d MMMM', locale).format(dt);
  } catch (_) {
    return '';
  }
}
