import '../../core/utils/money.dart';

/// Client ↔ freelancer conversation with optional escrow deals.
class DmConversation {
  const DmConversation({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.providerName,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  final String id;
  final String clientId;
  final String providerId;
  final String createdAt;
  final String updatedAt;
  final String? clientName;
  final String? providerName;
  final String? lastMessagePreview;
  final String? lastMessageAt;

  String peerNameFor(String userId) {
    if (userId == clientId) return providerName ?? 'Freelancer';
    return clientName ?? 'Client';
  }

  String peerIdFor(String userId) => userId == clientId ? providerId : clientId;
}

class DmMessage {
  const DmMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.kind,
    required this.body,
    required this.createdAt,
    this.dealId,
    this.senderName,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String kind; // text | offer | system
  final String body;
  final String createdAt;
  final String? dealId;
  final String? senderName;

  bool get isOffer => kind == 'offer';
  bool get isSystem => kind == 'system';
}

enum EscrowStatus {
  pendingPayment,
  funded,
  delivered,
  completed,
  cancelled,
}

extension EscrowStatusX on EscrowStatus {
  String get storageKey => switch (this) {
        EscrowStatus.pendingPayment => 'pending_payment',
        EscrowStatus.funded => 'funded',
        EscrowStatus.delivered => 'delivered',
        EscrowStatus.completed => 'completed',
        EscrowStatus.cancelled => 'cancelled',
      };

  static EscrowStatus fromKey(String? key) => switch (key) {
        'funded' => EscrowStatus.funded,
        'delivered' => EscrowStatus.delivered,
        'completed' => EscrowStatus.completed,
        'cancelled' => EscrowStatus.cancelled,
        _ => EscrowStatus.pendingPayment,
      };
}

class EscrowDeal {
  const EscrowDeal({
    required this.id,
    required this.conversationId,
    required this.clientId,
    required this.providerId,
    required this.title,
    required this.description,
    required this.amountCents,
    required this.platformFeeBps,
    required this.status,
    required this.createdAt,
    this.providerPayoutCents,
    this.platformFeeCents,
    this.fundedAt,
    this.deliveredAt,
    this.completedAt,
  });

  final String id;
  final String conversationId;
  final String clientId;
  final String providerId;
  final String title;
  final String description;
  final int amountCents;
  final int platformFeeBps;
  final EscrowStatus status;
  final int? providerPayoutCents;
  final int? platformFeeCents;
  final String createdAt;
  final String? fundedAt;
  final String? deliveredAt;
  final String? completedAt;

  String get amountLabel => Money.format(amountCents);

  int get computedPlatformFee => platformFeeCents ?? ((amountCents * platformFeeBps) ~/ 10000);

  int get computedProviderPayout =>
      providerPayoutCents ?? (amountCents - computedPlatformFee);
}
