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
                          Expanded(child: _Stat(s.teachers, '${stats.teachers}', Icons.school, AppColors.accentPurple)),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.bookings, '${stats.serviceBookings}', Icons.event_available, AppColors.accentGreen)),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.reports, '${stats.openReports}', Icons.flag, AppColors.error)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _Stat(s.learners, '${stats.learners}', Icons.menu_book, AppColors.accentBlue)),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.clients, '${stats.clients}', Icons.business_center, AppColors.accentOrange)),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.messages, '${stats.newMessages}', Icons.mail, AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _Stat(s.rooms, '${stats.roomBookings}', Icons.meeting_room, AppColors.navySoft)),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.printOrders, '${stats.printOrders}', Icons.print, AppColors.accentPink)),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(s.courses, '${stats.courses}', Icons.library_books, AppColors.accentPurple)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(s.adminQuickActions, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 10),
                      _AdminTile(Icons.people, s.manageUsers, s.manageUsersSub, AppColors.accentBlue, () => context.go('/admin/users')),
                      _AdminTile(Icons.flag_outlined, s.manageReports, s.manageReportsSub, AppColors.error, () => context.go('/admin/reports')),
                      _AdminTile(Icons.storefront, s.manageMarketplace, s.manageMarketplaceSub, AppColors.accentPurple, () => context.go('/admin/market')),
                      _AdminTile(Icons.meeting_room_outlined, s.manageRooms, s.manageRoomsSub, AppColors.primary, () => context.go('/admin/rooms')),
                      _AdminTile(Icons.print_outlined, s.managePrint, s.managePrintSub, AppColors.accentOrange, () => context.go('/admin/print')),
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
  const _Stat(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SoftMetricCard(
      background: color.withValues(alpha: 0.12),
      icon: icon,
      iconColor: color,
      label: label,
      value: value,
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
    ref.invalidate(allUsersProvider);
    ref.invalidate(adminStatsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.userDeleted)));
  }

  Future<void> _toggleBlock(BuildContext context, AppUser user, bool block) async {
    final s = S.of(context);
    await ref.read(databaseProvider).setUserBlocked(user.id, block);
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
      appBar: AppBar(
        title: Text(s.manageUsers),
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
            return Card(
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
      appBar: AppBar(title: Text(s.manageReports)),
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
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await ref.read(databaseProvider).updateReportStatus(r.id, 'resolved');
                                ref.invalidate(reportsProvider);
                                ref.invalidate(adminStatsProvider);
                              },
                              child: Text(s.resolve),
                            ),
                            TextButton(
                              onPressed: () async {
                                await ref.read(databaseProvider).updateReportStatus(r.id, 'dismissed');
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

    return Scaffold(
      appBar: AppBar(title: Text(s.manageMarketplace)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.bookings, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          AsyncValueContent(
            value: bookingsAsync,
            builder: (bookings) {
              if (bookings.isEmpty) return Text(s.noBookings, style: const TextStyle(color: AppColors.textSecondary));
              return Column(
                children: bookings
                    .take(8)
                    .map(
                      (b) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(b.serviceTitle ?? b.serviceId, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${b.clientName} → ${b.providerName}\n${Money.format(b.totalCents)}'),
                        isThreeLine: true,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(s.courses, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          AsyncValueContent(
            value: coursesAsync,
            builder: (courses) => Column(
              children: courses
                  .map(
                    (c) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.title),
                      subtitle: Text(c.teacherName ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () async {
                          await ref.read(databaseProvider).deleteCourse(c.id);
                          ref.invalidate(coursesProvider);
                          ref.invalidate(adminStatsProvider);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(s.services, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          AsyncValueContent(
            value: servicesAsync,
            builder: (services) => Column(
              children: services
                  .map(
                    (svc) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(svc.title),
                      subtitle: Text(svc.providerName ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () async {
                          await ref.read(databaseProvider).deleteService(svc.id);
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

    return Scaffold(
      appBar: AppBar(title: Text(s.manageRooms)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                          ref.invalidate(roomsProvider);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(s.roomBookings, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          AsyncValueContent(
            value: bookingsAsync,
            builder: (bookings) => Column(
              children: bookings
                  .map(
                    (b) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(b.roomName ?? b.roomId),
                      subtitle: Text('${b.userName} · ${b.billing} · ${Money.format(b.totalCents)}'),
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

// ── Print admin ─────────────────────────────────────────────────────

class AdminPrintScreen extends ConsumerWidget {
  const AdminPrintScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final ordersAsync = ref.watch(printOrdersProvider);
    final servicesAsync = ref.watch(printServicesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.managePrint)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.printCatalog, style: const TextStyle(fontWeight: FontWeight.w800)),
          AsyncValueContent(
            value: servicesAsync,
            builder: (items) => Column(
              children: items
                  .map((p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(p.title),
                        subtitle: Text('${p.priceLabel} / ${p.unit}'),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(s.printOrders, style: const TextStyle(fontWeight: FontWeight.w800)),
          AsyncValueContent(
            value: ordersAsync,
            builder: (orders) {
              if (orders.isEmpty) return Text(s.noOrders, style: const TextStyle(color: AppColors.textSecondary));
              return Column(
                children: orders.map((o) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(o.serviceTitle ?? o.serviceId, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${o.userName} · x${o.quantity} · ${Money.format(o.totalCents)}\n${o.status}'),
                      isThreeLine: true,
                      trailing: o.status == 'pending'
                          ? IconButton(
                              icon: const Icon(Icons.check_circle, color: AppColors.success),
                              onPressed: () async {
                                await ref.read(databaseProvider).updatePrintOrderStatus(o.id, 'done');
                                ref.invalidate(printOrdersProvider);
                                ref.invalidate(adminStatsProvider);
                              },
                            )
                          : null,
                    ),
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
      appBar: AppBar(
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
