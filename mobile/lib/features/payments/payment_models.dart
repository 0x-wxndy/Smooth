import 'package:flutter/material.dart';
import '../../shared/models/subscription_plan.dart';

/// What the mock payment unlocks after success.
enum PaymentPurpose { course, service, aiTokens, subscription, hubRoom, hubPrint, escrow }

enum PaymentGateway {
  edahabia,
  cib,
  card,
  coins,
}

class PaymentCheckoutArgs {
  const PaymentCheckoutArgs({
    required this.title,
    required this.amountCentimes,
    required this.purpose,
    this.subtitle,
    this.itemId,
    this.aiTokens,
    this.coinCost,
    this.subscriptionPlan,
    this.hubBilling,
    this.hubStartAt,
    this.hubEndAt,
    this.printScheduledAt,
    this.printNotes,
    this.printQuantity = 1,
  });

  final String title;
  final String? subtitle;
  final int amountCentimes;
  final PaymentPurpose purpose;
  final String? itemId;
  final int? aiTokens;
  final int? coinCost;
  final SubscriptionPlan? subscriptionPlan;
  final String? hubBilling;
  final DateTime? hubStartAt;
  final DateTime? hubEndAt;
  final DateTime? printScheduledAt;
  final String? printNotes;
  final int printQuantity;

  bool get canPayWithCoins => coinCost != null && coinCost! > 0;
}

class PaymentResultArgs {
  const PaymentResultArgs({
    required this.success,
    required this.title,
    required this.amountCentimes,
    required this.gateway,
    required this.purpose,
    this.message,
    this.itemId,
    this.aiTokens,
    this.transactionRef,
    this.subscriptionPlan,
  });

  final bool success;
  final String title;
  final int amountCentimes;
  final PaymentGateway gateway;
  final PaymentPurpose purpose;
  final String? message;
  final String? itemId;
  final int? aiTokens;
  final String? transactionRef;
  final SubscriptionPlan? subscriptionPlan;
}

extension PaymentGatewayX on PaymentGateway {
  String get label {
    switch (this) {
      case PaymentGateway.edahabia:
        return 'Edahabia';
      case PaymentGateway.cib:
        return 'CIB';
      case PaymentGateway.card:
        return 'Carte bancaire';
      case PaymentGateway.coins:
        return 'Samooth Coins';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentGateway.edahabia:
        return 'Carte Algérie Poste (SATIM)';
      case PaymentGateway.cib:
        return 'Carte Interbancaire';
      case PaymentGateway.card:
        return 'Visa / Mastercard (démo)';
      case PaymentGateway.coins:
        return 'Payer avec vos pièces';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentGateway.edahabia:
        return Icons.account_balance_wallet_rounded;
      case PaymentGateway.cib:
        return Icons.credit_card_rounded;
      case PaymentGateway.card:
        return Icons.payment_rounded;
      case PaymentGateway.coins:
        return Icons.monetization_on_rounded;
    }
  }

  Color get brandColor {
    switch (this) {
      case PaymentGateway.edahabia:
        return const Color(0xFFE8A317); // gold / Algérie Poste vibe
      case PaymentGateway.cib:
        return const Color(0xFF1E4D8C); // bank blue
      case PaymentGateway.card:
        return const Color(0xFF0F766E);
      case PaymentGateway.coins:
        return const Color(0xFFFBBF24);
    }
  }
}
