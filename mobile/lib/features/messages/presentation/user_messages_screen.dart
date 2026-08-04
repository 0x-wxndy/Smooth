import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/dm_model.dart';
import '../../../shared/models/hub_admin_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../admin/presentation/admin_screens.dart';

class MessagesTab extends ConsumerWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user?.role == UserRole.admin) {
      return const AdminMessagesScreen();
    }
    return const UserMessagesScreen();
  }
}

class UserMessagesScreen extends ConsumerStatefulWidget {
  const UserMessagesScreen({super.key});

  @override
  ConsumerState<UserMessagesScreen> createState() => _UserMessagesScreenState();
}

class _UserMessagesScreenState extends ConsumerState<UserMessagesScreen> {
  ContactMessage? _selected;

  Future<void> _compose() async {
    final s = S.of(context);
    final user = ref.read(authProvider).user;
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    var sending = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.composeMessage, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    AppConfig.hubEmail,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: subjectCtrl,
                    decoration: InputDecoration(labelText: s.subject, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bodyCtrl,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(labelText: s.message, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: sending || bodyCtrl.text.trim().isEmpty
                        ? null
                        : () async {
                            setState(() => sending = true);
                            await ref.read(databaseProvider).createContactMessage(
                                  userId: user?.id,
                                  name: user?.displayName ?? 'User',
                                  email: user?.email ?? AppConfig.hubEmail,
                                  subject: subjectCtrl.text.trim().isEmpty ? s.contactHub : subjectCtrl.text.trim(),
                                  body: bodyCtrl.text.trim(),
                                );
                            ref.invalidate(userMessagesProvider);
                            ref.invalidate(contactMessagesProvider);
                            ref.invalidate(adminStatsProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(s.messageSent), backgroundColor: AppColors.success),
                              );
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(s.sendMessage, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    subjectCtrl.dispose();
    bodyCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final msgsAsync = ref.watch(userMessagesProvider);
    final convsAsync = ref.watch(conversationsProvider);

    if (_selected != null) {
      return _MessageThreadView(
        message: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _compose,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_outlined),
        label: Text(s.composeMessage),
      ),
      body: AsyncValueContent(
        value: convsAsync,
        builder: (conversations) {
          return AsyncValueContent(
            value: msgsAsync,
            builder: (hubMsgs) {
              if (conversations.isEmpty && hubMsgs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.forum_outlined, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(s.noMessages, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _compose,
                          icon: const Icon(Icons.mail_outline),
                          label: Text(s.contactHub),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
                children: [
                  if (conversations.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        s.directMessages,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                    ...conversations.map(
                      (conv) => _DmInboxTile(
                        conversation: conv,
                        onTap: () => context.push('/messages/dm/${conv.id}'),
                        timeLabel: _formatTime(context, conv.lastMessageAt ?? conv.updatedAt),
                      ),
                    ),
                    if (hubMsgs.isNotEmpty) ...[
                      const Divider(height: 24),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          s.hubSupport,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ],
                  ...hubMsgs.map(
                    (msg) => Column(
                      children: [
                        _MessageInboxTile(
                          message: msg,
                          onTap: () => setState(() => _selected = msg),
                          timeLabel: _formatTime(context, msg.createdAt),
                        ),
                        const Divider(height: 1, indent: 76),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DmInboxTile extends ConsumerWidget {
  const _DmInboxTile({
    required this.conversation,
    required this.onTap,
    required this.timeLabel,
  });

  final DmConversation conversation;
  final VoidCallback onTap;
  final String timeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user;
    final peerName = me == null ? 'User' : conversation.peerNameFor(me.id);
    final preview = conversation.lastMessagePreview ?? '';

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
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
                            peerName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                        Text(timeLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInboxTile extends StatelessWidget {
  const _MessageInboxTile({
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
                child: Icon(
                  Icons.support_agent_rounded,
                  color: unread ? AppColors.primary : AppColors.navy,
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
                            message.subject,
                            style: TextStyle(
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: unread ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageThreadView extends ConsumerStatefulWidget {
  const _MessageThreadView({required this.message, required this.onBack});

  final ContactMessage message;
  final VoidCallback onBack;

  @override
  ConsumerState<_MessageThreadView> createState() => _MessageThreadViewState();
}

class _MessageThreadViewState extends ConsumerState<_MessageThreadView> {
  final _replyCtrl = TextEditingController();
  late List<ContactMessage> _thread = [widget.message];
  bool _sending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    final user = ref.read(authProvider).user;
    setState(() => _sending = true);
    final sent = await ref.read(databaseProvider).createContactMessage(
          userId: user?.id,
          name: user?.displayName ?? widget.message.name,
          email: user?.email ?? widget.message.email,
          subject: widget.message.subject,
          body: text,
        );
    ref.invalidate(userMessagesProvider);
    if (!mounted) return;
    setState(() {
      _thread = [..._thread, sent];
      _replyCtrl.clear();
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message.subject, style: const TextStyle(fontSize: 16)),
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
                padding: const EdgeInsets.all(16),
                children: [
                  _ChatBubble(
                    sender: 'Samooth Hub',
                    body: s.contactHubWelcome,
                    incoming: true,
                  ),
                  const SizedBox(height: 8),
                  for (final m in _thread) ...[
                    _ChatBubble(
                      sender: m.name,
                      body: m == _thread.first ? '${m.subject}\n\n${m.body}' : m.body,
                      incoming: false,
                    ),
                    const SizedBox(height: 8),
                  ],
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyCtrl,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.sender,
    required this.body,
    required this.incoming,
  });

  final String sender;
  final String body;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: incoming ? Colors.white : AppColors.primarySoft,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(incoming ? 4 : 16),
            bottomRight: Radius.circular(incoming ? 16 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: incoming ? AppColors.primary : AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

String _formatTime(BuildContext context, String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return DateFormat.jm(Localizations.localeOf(context).languageCode).format(dt);
    }
    return DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(dt);
  } catch (_) {
    return iso;
  }
}
