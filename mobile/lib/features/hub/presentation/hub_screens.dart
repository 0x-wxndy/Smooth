import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../../../shared/widgets/smooth_components.dart';

/// Compact promo for market / dashboards — book rooms & print (teachers, clients).
class HubFacilitiesPromo extends StatelessWidget {
  const HubFacilitiesPromo({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BorderedSection(
      borderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apartment_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.hubFacilities, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      s.hubFacilitiesSub,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/hub/rooms'),
                  icon: const Icon(Icons.meeting_room_outlined, size: 18),
                  label: Text(s.rentRooms, style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/hub/print'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: Text(s.printingServices, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => context.push('/hub'), child: Text(s.seeAll)),
          ),
        ],
      ),
    );
  }
}

/// Hub facilities for teachers/freelancers/clients: rooms + print + contact.
class HubFacilitiesScreen extends ConsumerWidget {
  const HubFacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final role = ref.watch(authProvider).user?.role;

    if (role == UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: Text(s.hubFacilities)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(s.adminHubRedirect, textAlign: TextAlign.center, style: const TextStyle(height: 1.45)),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(s.openAdminPanel),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.hubFacilities)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(s.hubFacilitiesSub, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 16),
          _HubCard(
            icon: Icons.meeting_room_rounded,
            color: AppColors.primary,
            title: s.rentRooms,
            subtitle: s.rentRoomsSub,
            onTap: () => context.push('/hub/rooms'),
          ),
          _HubCard(
            icon: Icons.print_rounded,
            color: AppColors.accentOrange,
            title: s.printingServices,
            subtitle: s.printingServicesSub,
            onTap: () => context.push('/hub/print'),
          ),
          _HubCard(
            icon: Icons.support_agent_rounded,
            color: AppColors.accentGreen,
            title: s.contactHub,
            subtitle: s.contactHubSub,
            onTap: () => context.push('/hub/contact'),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.35)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class RoomsCatalogScreen extends ConsumerWidget {
  const RoomsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final roomsAsync = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.rentRooms)),
      body: AsyncValueContent(
        value: roomsAsync,
        builder: (rooms) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (_, i) {
            final room = rooms[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: room.available ? AppColors.pastelMint : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room.available ? s.available : s.unavailable,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: room.available ? AppColors.success : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(room.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35)),
                    const SizedBox(height: 8),
                    Text('${s.capacity}: ${room.capacity} · ${room.priceHourLabel} · ${room.priceDayLabel}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    if (room.amenities.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: room.amenities
                            .map((a) => Chip(label: Text(a, style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact))
                            .toList(),
                      ),
                    ],
                    if (room.available) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _book(context, ref, room.id, 'hour'),
                              child: Text(s.bookHours),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _book(context, ref, room.id, 'day'),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                              child: Text(s.bookDay),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _book(BuildContext context, WidgetRef ref, String roomId, String billing) async {
    final s = S.of(context);
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;
    final booking = await ref.read(databaseProvider).bookRoom(
          roomId: roomId,
          userId: userId,
          billing: billing,
        );
    ref.invalidate(roomBookingsProvider);
    ref.invalidate(adminStatsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${s.roomBooked} · ${Money.format(booking.totalCents)}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class PrintCatalogScreen extends ConsumerWidget {
  const PrintCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final servicesAsync = ref.watch(printServicesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.printingServices)),
      body: AsyncValueContent(
        value: servicesAsync,
        builder: (items) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final p = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      '${p.description}\n${p.priceLabel} / ${p.unit}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => _order(context, ref, p.id),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text(s.order),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _order(BuildContext context, WidgetRef ref, String serviceId) async {
    final s = S.of(context);
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;
    final order = await ref.read(databaseProvider).createPrintOrder(
          serviceId: serviceId,
          userId: userId,
          quantity: 1,
          notes: 'Commande demo hub',
        );
    ref.invalidate(printOrdersProvider);
    ref.invalidate(adminStatsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${s.printOrdered} · ${Money.format(order.totalCents)}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class ContactHubScreen extends ConsumerStatefulWidget {
  const ContactHubScreen({super.key});

  @override
  ConsumerState<ContactHubScreen> createState() => _ContactHubScreenState();
}

class _ContactHubScreenState extends ConsumerState<ContactHubScreen> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final s = S.of(context);
    if (_subject.text.trim().isEmpty || _body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.fillRequired)));
      return;
    }
    final user = ref.read(authProvider).user;
    setState(() => _sending = true);
    await ref.read(databaseProvider).createContactMessage(
          userId: user?.id,
          name: user?.displayName ?? 'Guest',
          email: user?.email ?? AppConfig.hubEmail,
          subject: _subject.text.trim(),
          body: _body.text.trim(),
        );
    ref.invalidate(contactMessagesProvider);
    ref.invalidate(userMessagesProvider);
    ref.invalidate(adminStatsProvider);
    setState(() => _sending = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.messageSent), backgroundColor: AppColors.success),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.contactHub),
            Text(
              AppConfig.hubEmail,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
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
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  _HubChatBubble(
                    senderName: 'Samooth Hub',
                    body: s.contactHubWelcome,
                    incoming: true,
                    hubAvatar: true,
                  ),
                  if (_subject.text.isNotEmpty || _body.text.isNotEmpty)
                    _HubChatBubble(
                      senderName: user?.displayName ?? 'You',
                      body: [
                        if (_subject.text.trim().isNotEmpty) _subject.text.trim(),
                        if (_body.text.trim().isNotEmpty) _body.text.trim(),
                      ].join('\n\n'),
                      incoming: false,
                    ),
                ],
              ),
            ),
          ),
          Material(
            elevation: 8,
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _subject,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: s.subject,
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _body,
                            onChanged: (_) => setState(() {}),
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: s.typeYourMessage,
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          onPressed: _sending ? null : _send,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ],
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

class _HubChatBubble extends StatelessWidget {
  const _HubChatBubble({
    required this.senderName,
    required this.body,
    required this.incoming,
    this.hubAvatar = false,
  });

  final String senderName;
  final String body;
  final bool incoming;
  final bool hubAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: incoming ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (incoming) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: hubAvatar
                  ? const Icon(Icons.hub_outlined, size: 16, color: AppColors.primary)
                  : Text(senderName.characters.first.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: incoming ? Colors.white : AppColors.primary,
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
              child: Text(
                body,
                style: TextStyle(
                  color: incoming ? AppColors.textPrimary : Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportUserScreen extends ConsumerStatefulWidget {
  const ReportUserScreen({super.key, required this.reportedUserId, required this.reportedName});

  final String reportedUserId;
  final String reportedName;

  @override
  ConsumerState<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends ConsumerState<ReportUserScreen> {
  String _reason = 'Comportement abusif';
  final _details = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final reporterId = ref.read(authProvider).user?.id;
    if (reporterId == null) return;
    setState(() => _sending = true);
    await ref.read(databaseProvider).createReport(
          reporterId: reporterId,
          reportedUserId: widget.reportedUserId,
          reason: _reason,
          details: _details.text.trim().isEmpty ? null : _details.text.trim(),
        );
    ref.invalidate(reportsProvider);
    ref.invalidate(adminStatsProvider);
    setState(() => _sending = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.reportSent), backgroundColor: AppColors.success),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.reportUser)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('${s.reported}: ${widget.reportedName}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _reason,
            decoration: InputDecoration(labelText: s.reason, border: const OutlineInputBorder()),
            items: [
              'Comportement abusif',
              'Contenu inapproprié',
              'Fraude / arnaque',
              'Spam',
              'Autre',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _reason = v ?? _reason),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            maxLines: 4,
            decoration: InputDecoration(labelText: s.details, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SmoothButton(label: s.submitReport, isLoading: _sending, onPressed: _submit),
        ],
      ),
    );
  }
}

/// Pick a user to report — search by name or email.
class ReportPickerScreen extends ConsumerStatefulWidget {
  const ReportPickerScreen({super.key});

  @override
  ConsumerState<ReportPickerScreen> createState() => _ReportPickerScreenState();
}

class _ReportPickerScreenState extends ConsumerState<ReportPickerScreen> {
  final _query = TextEditingController();
  List<AppUser> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    final me = ref.read(authProvider).user?.id;
    if (value.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final hits = await ref.read(databaseProvider).searchUsers(value, excludeUserId: me);
    if (!mounted) return;
    setState(() {
      _results = hits;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.reportUser)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _query,
              autofocus: true,
              decoration: InputDecoration(
                hintText: s.searchUserToReport,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(s.reportUserSub, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(height: 8),
          if (_searching) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _query.text.trim().length < 2
                ? Center(
                    child: Text(
                      s.searchUserHint,
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _results.isEmpty
                    ? Center(child: Text(s.noUsersFound))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final u = _results[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text(u.displayName.characters.first.toUpperCase())),
                            title: Text(u.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${u.email} · ${roleDisplayName(u.role)}'),
                            trailing: const Icon(Icons.flag_outlined, color: AppColors.error),
                            onTap: () => context.push('/report/${u.id}', extra: u.displayName),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
