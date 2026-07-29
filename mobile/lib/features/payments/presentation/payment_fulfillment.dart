import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../payment_models.dart';

/// Applies post-payment side effects (enroll, tokens, etc.).
abstract final class PaymentFulfillment {
  static Future<void> apply(
    BuildContext context,
    PaymentCheckoutArgs args,
    PaymentGateway gateway,
  ) async {
    // Fulfillment needs a ProviderScope — use a Consumer-less approach via
    // looking up ProviderScope. Or pass WidgetRef. Gateways call this from
    // State; we'll use ProviderScope.containerOf.
    final container = ProviderScope.containerOf(context, listen: false);
    final userId = container.read(authProvider).user?.id;
    if (userId == null) return;

    final db = container.read(databaseProvider);

    switch (args.purpose) {
      case PaymentPurpose.course:
        if (args.itemId != null) {
          await db.enrollCourse(userId, args.itemId!);
          container.invalidate(coursesProvider);
          container.invalidate(courseProvider(args.itemId!));
        }
      case PaymentPurpose.service:
        if (args.itemId != null) {
          await db.awardBookingToProvider(args.itemId!, clientId: userId);
        }
      case PaymentPurpose.aiTokens:
        if (args.aiTokens != null && args.aiTokens! > 0) {
          await db.creditAiTokens(userId, args.aiTokens!);
          container.invalidate(aiQuotaProvider);
          container.invalidate(gamificationProvider);
        }
    }
  }
}
